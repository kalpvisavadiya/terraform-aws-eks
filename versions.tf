terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # The workflow supplies the S3 bucket name during `terraform init`.
  # The bucket is bootstrapped by .github/workflows/terraform.yml.
  backend "s3" {
    key         = "eks/terraform.tfstate"
    encrypt     = true
    use_lockfile = true
  }
}
