terraform {
  backend "s3" {
    bucket         = "terraform-aldarull"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
  }
}