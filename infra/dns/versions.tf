terraform {
  required_version = ">= 1.5"

  required_providers {
    porkbun = {
      source  = "marcfrederick/porkbun"
      version = "~> 1.0"
    }
  }
}
