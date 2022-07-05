provider "aws" { 
    alias = "east"
    region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::466052212456:role/s3_replication_role"
   }
 }


 