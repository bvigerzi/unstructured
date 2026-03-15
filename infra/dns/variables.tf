variable "porkbun_api_key" {
  description = "Porkbun API key"
  type        = string
  sensitive   = true
}

variable "porkbun_secret_key" {
  description = "Porkbun secret API key"
  type        = string
  sensitive   = true
}

variable "bunny_pullzone_cname" {
  description = "Bunny.net pull zone hostname (from CDN terraform output)"
  type        = string
}

variable "site_domain" {
  description = "Primary site domain"
  type        = string
  default     = "unstructured.fyi"
}
