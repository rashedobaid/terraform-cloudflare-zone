output "id" {
  description = "The unique identifier of the Cloudflare zone."
  value       = try(local.zone_id, null)
}

output "record_hostnames_to_ids" {
  description = "Map of DNS record hostnames to their corresponding record IDs."
  value       = { for record in cloudflare_dns_record.default : record.hostname => record.id... if local.records_enabled }
}

output "type" {
  description = "The zone type, indicating the plan or configuration applied (e.g., 'full' or 'partial')."
  value       = join("", cloudflare_zone.default[*].type)
}

output "vanity_name_servers" {
  description = "List of custom vanity name servers assigned to the zone, if configured."
  value       = try(cloudflare_zone.default[*].vanity_name_servers, null)
}

output "meta_phishing_detected" {
  description = "Indicates whether phishing content has been detected on the zone."
  value       = join("", cloudflare_zone.default[*].meta.phishing_detected)
}

output "status" {
  description = "Current status of the zone (e.g., 'active', 'pending')."
  value       = join("", cloudflare_zone.default[*].status)
}

output "name_servers" {
  description = "List of Cloudflare-assigned name servers. Only populated for zones using full DNS setup."
  value       = try(cloudflare_zone.default[*].name_servers, null)
}

output "verification_key" {
  description = "TXT record value used to verify domain ownership. Applicable only for zones of type 'partial'."
  value       = join("", cloudflare_zone.default[*].verification_key)
}
