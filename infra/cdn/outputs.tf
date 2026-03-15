output "pullzone_hostname" {
  description = "Bunny.net pull zone hostname (use for DNS CNAME/ALIAS)"
  value       = bunnynet_pullzone.site.cdn_domain
}

output "storage_zone_id" {
  description = "Bunny.net storage zone ID"
  value       = bunnynet_storage_zone.site.id
}

output "pullzone_id" {
  description = "Bunny.net pull zone ID"
  value       = bunnynet_pullzone.site.id
}
