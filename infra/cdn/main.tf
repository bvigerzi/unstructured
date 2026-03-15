resource "bunnynet_storage_zone" "site" {
  name      = var.storage_zone_name
  region    = "DE"
  zone_tier = "Standard"
}

resource "bunnynet_pullzone" "site" {
  name = var.storage_zone_name

  origin {
    type        = "StorageZone"
    storagezone = bunnynet_storage_zone.site.id
  }

  cache_enabled = true

  tls_support = []

  routing {
    tier = "Standard"
  }
}

resource "bunnynet_pullzone_hostname" "apex" {
  pullzone    = bunnynet_pullzone.site.id
  name        = var.site_domain
  tls_enabled = true
  force_ssl   = true
}

resource "bunnynet_pullzone_hostname" "www" {
  pullzone    = bunnynet_pullzone.site.id
  name        = "www.${var.site_domain}"
  tls_enabled = true
  force_ssl   = true
}

resource "bunnynet_pullzone_edgerule" "www_redirect" {
  pullzone    = bunnynet_pullzone.site.id
  description = "Redirect www to apex domain"
  enabled     = true

  action            = "Redirect"
  action_parameter1 = "https://${var.site_domain}{{path}}"
  action_parameter2 = "301"

  match_type = "MatchAny"

  triggers {
    type       = "RequestHeader"
    match_type = "MatchAny"
    patterns   = ["www.${var.site_domain}"]
    parameter1 = "Host"
  }
}
