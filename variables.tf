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

variable "zone_settings" {
  description = "Zone settings to manage, keyed by Cloudflare setting ID; unset settings are left unmanaged. `zero_rtt` maps to the `0rtt` setting, and `ssl_recommender` is sent as the resource's `enabled` attribute."
  type = object({
    zero_rtt                        = optional(string)
    advanced_ddos                   = optional(string)
    always_online                   = optional(string)
    always_use_https                = optional(string)
    automatic_https_rewrites        = optional(string)
    brotli                          = optional(string)
    browser_check                   = optional(string)
    content_converter               = optional(string)
    development_mode                = optional(string)
    early_hints                     = optional(string)
    email_obfuscation               = optional(string)
    hotlink_protection              = optional(string)
    http2                           = optional(string)
    http3                           = optional(string)
    ip_geolocation                  = optional(string)
    ipv6                            = optional(string)
    mirage                          = optional(string)
    opportunistic_encryption        = optional(string)
    opportunistic_onion             = optional(string)
    orange_to_orange                = optional(string)
    origin_error_page_pass_thru     = optional(string)
    pre_render                      = optional(string)
    prefetch_preload                = optional(string)
    privacy_pass                    = optional(string)
    redirects_for_ai_training       = optional(string)
    replace_insecure_js             = optional(string)
    response_buffering              = optional(string)
    rocket_loader                   = optional(string)
    search_for_agents               = optional(string)
    server_side_exclude             = optional(string)
    sha1_support                    = optional(string)
    sort_query_string_for_cache     = optional(string)
    tls_1_2_only                    = optional(string)
    tls_client_auth                 = optional(string)
    true_client_ip_header           = optional(string)
    waf                             = optional(string)
    webmcp_enabled                  = optional(string)
    webp                            = optional(string)
    websockets                      = optional(string)
    cache_level                     = optional(string)
    cname_flattening                = optional(string)
    h2_prioritization               = optional(string)
    image_resizing                  = optional(string)
    min_tls_version                 = optional(string)
    origin_max_http_version         = optional(string)
    polish                          = optional(string)
    pseudo_ipv4                     = optional(string)
    security_level                  = optional(string)
    ssl                             = optional(string)
    tls_1_3                         = optional(string)
    transformations                 = optional(string)
    transformations_allowed_origins = optional(string)
    webmcp_mcp_url                  = optional(string)
    webmcp_packs                    = optional(string)
    browser_cache_ttl               = optional(number)
    challenge_ttl                   = optional(number)
    edge_cache_ttl                  = optional(number)
    max_upload                      = optional(number)
    origin_h2_max_streams           = optional(number)
    proxy_read_timeout              = optional(number)
    ciphers                         = optional(list(string))
    ssl_recommender                 = optional(bool)
    aegis = optional(object({
      enabled = bool
      pool_id = string
    }))
    automatic_platform_optimization = optional(object({
      cache_by_device_type = bool
      cf                   = bool
      enabled              = bool
      hostnames            = list(string)
      wordpress            = bool
      wp_plugin            = bool
    }))
    nel = optional(object({
      enabled = bool
    }))
    security_header = optional(object({
      strict_transport_security = object({
        enabled            = optional(bool, false)
        include_subdomains = optional(bool, false)
        max_age            = optional(number, 0)
        nosniff            = optional(bool, false)
        preload            = optional(bool, false)
      })
    }))
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for name in [
        "zero_rtt", "advanced_ddos", "always_online", "always_use_https", "automatic_https_rewrites", "brotli",
        "browser_check", "content_converter", "development_mode", "early_hints", "email_obfuscation",
        "hotlink_protection", "http2", "http3", "ip_geolocation", "ipv6", "mirage", "opportunistic_encryption",
        "opportunistic_onion", "orange_to_orange", "origin_error_page_pass_thru", "pre_render", "prefetch_preload",
        "privacy_pass", "redirects_for_ai_training", "replace_insecure_js", "response_buffering", "rocket_loader",
        "search_for_agents", "server_side_exclude", "sha1_support", "sort_query_string_for_cache", "tls_1_2_only",
        "tls_client_auth", "true_client_ip_header", "waf", "webmcp_enabled", "webp", "websockets",
      ] : var.zone_settings[name] == null ? true : contains(["on", "off"], var.zone_settings[name])
    ])
    error_message = "On/off zone settings (e.g. always_use_https, brotli, http3) must be \"on\" or \"off\"."
  }

  validation {
    condition = alltrue([
      for name, allowed in {
        cache_level             = ["aggressive", "basic", "simplified"]
        cname_flattening        = ["flatten_at_root", "flatten_all"]
        h2_prioritization       = ["on", "off", "custom"]
        image_resizing          = ["on", "off", "open"]
        min_tls_version         = ["1.0", "1.1", "1.2", "1.3"]
        origin_max_http_version = ["1", "2"]
        polish                  = ["off", "lossless", "lossy"]
        pseudo_ipv4             = ["off", "add_header", "overwrite_header"]
        security_level          = ["off", "essentially_off", "low", "medium", "high", "under_attack"]
        ssl                     = ["off", "flexible", "full", "strict"]
        tls_1_3                 = ["on", "off", "zrt"]
        transformations         = ["on", "off", "open"]
      } : var.zone_settings[name] == null ? true : contains(allowed, var.zone_settings[name])
    ])
    error_message = "Invalid value for an enum zone setting (cache_level, cname_flattening, h2_prioritization, image_resizing, min_tls_version, origin_max_http_version, polish, pseudo_ipv4, security_level, ssl, tls_1_3 or transformations)."
  }

  validation {
    condition = alltrue([
      for name, allowed in {
        challenge_ttl  = [300, 900, 1800, 2700, 3600, 7200, 10800, 14400, 28800, 57600, 86400, 604800, 2592000, 31536000]
        edge_cache_ttl = [30, 60, 300, 1200, 1800, 3600, 7200, 10800, 14400, 18000, 28800, 43200, 57600, 72000, 86400, 172800, 259200, 345600, 432000, 518400, 604800]
        max_upload     = [100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 350, 375, 400, 425, 450, 475, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000]
      } : var.zone_settings[name] == null ? true : contains(allowed, var.zone_settings[name])
    ])
    error_message = "challenge_ttl, edge_cache_ttl and max_upload must be one of the values Cloudflare accepts for that setting."
  }

  validation {
    condition = alltrue([
      for name in ["browser_cache_ttl", "origin_h2_max_streams", "proxy_read_timeout"] :
      var.zone_settings[name] == null ? true : var.zone_settings[name] >= 0
    ])
    error_message = "browser_cache_ttl, origin_h2_max_streams and proxy_read_timeout must not be negative."
  }
}

variable "rulesets" {
  description = "List of Rulesets to be created within the zone."
  type = list(object({
    name        = optional(string, "default")
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
