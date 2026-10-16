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

# AI usage preference on every response (IETF aipref Content-Usage header).
# Mirrors the Content-Usage line in public/robots.txt; see docs/no-ai-scraping.md.
resource "bunnynet_pullzone_edgerule" "ai_usage_header" {
  pullzone    = bunnynet_pullzone.site.id
  description = "Content-Usage: no AI training or AI use"
  enabled     = true

  action            = "SetResponseHeader"
  action_parameter1 = "Content-Usage"
  action_parameter2 = "train-ai=n, ai-use=n, search=y"

  match_type = "MatchAny"

  triggers {
    type       = "Url"
    match_type = "MatchAny"
    patterns   = ["*"]
  }
}
