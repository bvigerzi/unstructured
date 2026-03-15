# Note: Porkbun's Terraform provider may not support ALIAS records.
# If `terraform plan` fails on the apex record, create it manually
# in the Porkbun dashboard and remove/comment the resource below.
# See README.md for manual instructions.

resource "porkbun_dns_record" "apex" {
  domain    = var.site_domain
  subdomain = ""
  type      = "ALIAS"
  content   = var.bunny_pullzone_cname
  ttl       = 600
}

resource "porkbun_dns_record" "www" {
  domain  = var.site_domain
  subdomain = "www"
  type    = "CNAME"
  content = var.bunny_pullzone_cname
  ttl     = 600
}
