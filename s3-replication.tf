provider "aws" { 
  region = "us-east-1"
}

#create a source bucket
# resource "aws_s3_bucket" "source" {
#   bucket   = "s3-source-bucket-replication-testing"
  
# }
data "aws_s3_bucket" "source" {
  bucket = "backend-tf"
  
}

# resource "aws_s3_bucket_versioning" "source-version" {
#   bucket = aws_s3_bucket.source.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

#create a destination bucket & attach bucket policy
resource "aws_s3_bucket" "destination" {
  provider = aws.east
  bucket = "s3-destination-bucket-replication-testing"

}
#create_dest_bucket_policy
resource "aws_s3_bucket_policy" "dest-bucket-policy" {
  provider = aws.east
  bucket = aws_s3_bucket.destination.id

     policy = <<POLICY
{
    "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "access_to_replicate_object",
              "Effect": "Allow",
              "Principal": {
              "AWS": "${aws_iam_role.replication.arn}"
              },
               "Action": [
                  "s3:ReplicateObject"
              ],
              "Resource": [
                  "arn:aws:s3:::s3-destination-bucket-replication-testing", 
                  "arn:aws:s3:::s3-destination-bucket-replication-testing/*"
              ]
          },
          {
              "Sid": "Deny-delete-object",
              "Effect": "Deny",
              "Principal": {
                "AWS": "arn:aws:iam::466052212456:user/account-b"
              },
                "Action": [
                  "s3:DeleteObject",
                  "s3:DeleteObjectVersion",
                  "s3:DeleteBucket"
              ],
              "Resource": [
                  "arn:aws:s3:::s3-destination-bucket-replication-testing",
                  "arn:aws:s3:::s3-destination-bucket-replication-testing/*"
              ]
           },
           {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::951600338934:root"
            },
            "Action":[
              "s3:ListBucket",
                "s3:PutObject",
                "s3:GetObjectAcl",
                "s3:GetObject",
                "s3:PutObjectVersionAcl",
                "s3:GetObjectTagging",
                "s3:DeleteObject",
                "s3:GetBucketLocation",
                "s3:PutObjectAcl"
            ],

            "Resource": [
              "arn:aws:s3:::s3-destination-bucket-replication-testing",
              "arn:aws:s3:::s3-destination-bucket-replication-testing/*"
            ]
        }   
      ]
}    
POLICY
}

resource "aws_s3_bucket_versioning" "destination-version" {
  provider = aws.east
  bucket = aws_s3_bucket.destination.id
  versioning_configuration {
    status = "Enabled"
  }
}


#create a replication role
resource "aws_iam_role" "replication" {
  name = "s3-replication-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

#create a replication policy
resource "aws_iam_policy" "replication" {
  name = "s3-replication-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${data.aws_s3_bucket.source.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "${data.aws_s3_bucket.source.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.destination.arn}/*"
    }
  ]
}
POLICY
}

#Attachment the replication role & policy
resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}



#replication configuration
resource "aws_s3_bucket_replication_configuration" "replication" {
 
  # Must have bucket versioning enabled first
 
  depends_on = [aws_s3_bucket_versioning.destination-version]
    
  role   = aws_iam_role.replication.arn
  bucket = data.aws_s3_bucket.source.id

  rule {
    id = "replication-1"

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "STANDARD"
    }

  }
}


