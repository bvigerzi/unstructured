output "apex_record_id" {
  description = "Porkbun DNS record ID for apex domain"
  value       = porkbun_dns_record.apex.id
}

output "www_record_id" {
  description = "Porkbun DNS record ID for www subdomain"
  value       = porkbun_dns_record.www.id
}
