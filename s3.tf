terraform {
  backend "s3" {
    bucket = "scoot-terraform-new"
    key    = "state"
    region = "us-west-2"
  }
}
