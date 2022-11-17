terraform {
  backend "s3" {
    bucket         = "hypothesis-terraform-state"
    key            = "report-prod/s3/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "hypothesis-terraform-state"
    encrypt        = true
  }
}
