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
  type = list(object({
    name     = string
    type     = string
    ttl      = optional(number, 1)
    content  = optional(string)
    data     = optional(map(any))
    priority = optional(number)
    proxied  = optional(bool)
    comment  = optional(string)
    settings = optional(map(any))
  }))
  default = []
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
  type = list(object({
    name        = optional(string)
    phase       = string
    description = optional(string)
    rules = optional(list(object({
      action      = string
      expression  = string
      description = optional(string)
      enabled     = optional(bool)
      ref         = optional(string)
      action_parameters = optional(object({
        id                       = optional(string)
        ruleset                  = optional(string)
        version                  = optional(string)
        phases                   = optional(list(string))
        products                 = optional(list(string))
        host_header              = optional(string)
        status_code              = optional(number)
        content                  = optional(string)
        content_type             = optional(string)
        polish                   = optional(string)
        security_level           = optional(string)
        ssl                      = optional(string)
        automatic_https_rewrites = optional(bool)
        mirage                   = optional(bool)
        rocket_loader            = optional(bool)
        bic                      = optional(bool)
        hotlink_protection       = optional(bool)
        cache                    = optional(bool)
        origin_cache_control     = optional(bool)
        browser_ttl = optional(object({
          mode    = string
          default = optional(number)
        }))
        edge_ttl = optional(object({
          mode    = string
          default = optional(number)
          status_code_ttl = optional(list(object({
            value       = number
            status_code = optional(number)
            status_code_range = optional(object({
              from = optional(number)
              to   = optional(number)
            }))
          })))
        }))
        cache_key = optional(object({
          ignore_query_strings_order = optional(bool)
          cache_by_device_type       = optional(bool)
          cache_deception_armor      = optional(bool)
          custom_key = optional(object({
            cookie = optional(object({
              include        = optional(list(string))
              check_presence = optional(list(string))
            }))
            header = optional(object({
              include        = optional(list(string))
              check_presence = optional(list(string))
              exclude_origin = optional(bool)
            }))
            host = optional(object({
              resolved = optional(bool)
            }))
            user = optional(object({
              device_type = optional(bool)
              geo         = optional(bool)
              lang        = optional(bool)
            }))
            query_string = optional(object({
              include = optional(object({
                all  = optional(bool)
                list = optional(list(string))
              }))
              exclude = optional(object({
                all  = optional(bool)
                list = optional(list(string))
              }))
            }))
          }))
        }))
        serve_stale = optional(object({
          disable_stale_while_updating = optional(bool)
        }))
        headers = optional(map(object({
          operation  = string
          value      = optional(string)
          expression = optional(string)
        })))
        from_value = optional(object({
          status_code           = optional(number)
          preserve_query_string = optional(bool)
          target_url = optional(object({
            value      = optional(string)
            expression = optional(string)
          }))
        }))
        uri = optional(object({
          path = optional(object({
            value      = optional(string)
            expression = optional(string)
          }))
          query = optional(object({
            value      = optional(string)
            expression = optional(string)
          }))
        }))
        overrides = optional(object({
          action            = optional(string)
          enabled           = optional(bool)
          sensitivity_level = optional(string)
          categories = optional(list(object({
            category          = string
            action            = optional(string)
            enabled           = optional(bool)
            sensitivity_level = optional(string)
          })))
          rules = optional(list(object({
            id                = string
            action            = optional(string)
            enabled           = optional(bool)
            score_threshold   = optional(number)
            sensitivity_level = optional(string)
          })))
        }))
      }))
      logging = optional(object({
        enabled = optional(bool)
      }))
      ratelimit = optional(object({
        characteristics     = list(string)
        period              = number
        requests_per_period = optional(number)
        mitigation_timeout  = optional(number)
        counting_expression = optional(string)
        requests_to_origin  = optional(bool)
        score_per_period    = optional(number)
      }))
      exposed_credential_check = optional(object({
        username_expression = string
        password_expression = string
      }))
    })), [])
  }))
  default = []
}
