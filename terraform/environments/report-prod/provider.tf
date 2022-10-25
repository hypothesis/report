provider "aws" {
  region                   = "us-west-1"
  shared_credentials_files = ["~/.aws/credentials"]

  default_tags {
    tags = var.tags
  }
}
