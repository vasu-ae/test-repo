terraform {
  backend "s3" {
    
    bucket = "backend-tf"
    key    = "s3-sync/terraform.tfstate"
    region = "us-east-1"
    acl    = "bucket-owner-full-control"
  }
}