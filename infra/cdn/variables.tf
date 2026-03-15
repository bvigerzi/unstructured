variable "bunny_api_key" {
  description = "Bunny.net API key"
  type        = string
  sensitive   = true
}

variable "site_domain" {
  description = "Primary site domain"
  type        = string
  default     = "unstructured.fyi"
}

variable "storage_zone_name" {
  description = "Name for the Bunny.net storage zone"
  type        = string
  default     = "unstructured-fyi"
}
