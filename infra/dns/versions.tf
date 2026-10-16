terraform {
  required_version = ">= 1.14"

  required_providers {
    porkbun = {
      source  = "marcfrederick/porkbun"
      version = "~> 1.0"
    }
  }
}
