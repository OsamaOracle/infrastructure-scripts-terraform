provider "aws" {
  alias                   = "useast1"
  region                  = "us-east-1"
  allowed_account_ids = ["600347145726"]
}

provider "aws" {
  alias                   = "eucentral1"
  region                  = "eu-central-1"
  allowed_account_ids = ["600347145726"]
}
