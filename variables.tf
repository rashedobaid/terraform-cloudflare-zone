variable "account_id" {
  description = "The Cloudflare account ID associated with the zone."
  type        = string
}

variable "zone" {
  description = "The domain name of the Cloudflare zone (e.g., example.com)."
  type        = string
}

variable "zone_enabled" {
  description = "Determines whether to create a new DNS zone. If set to false, uses an existing zone."
  type        = bool
  default     = true
}

variable "type" {
  description = "Type of zone: 'full' for Cloudflare-managed DNS, or 'partial' for CNAME setup."
  type        = string
  default     = "full"
}

variable "records" {
  description = "List of DNS records to be created within the zone."
  type        = list(any)
  default     = []
}

variable "argo_enabled" {
  description = "Whether to enable Cloudflare Argo for the zone."
  type        = bool
  default     = false
}

variable "argo_tiered_caching_enabled" {
  description = "Enable tiered caching as part of Argo features."
  type        = bool
  default     = true
}

variable "argo_smart_routing_enabled" {
  description = "Enable smart routing as part of Argo features."
  type        = bool
  default     = true
}

variable "rulesets" {
  description = "List of Rulesets to be created within the zone."
  type        = list(any)
  default     = []
}