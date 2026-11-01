# Terraform Cloudflare Zone

Terraform module that manages Cloudflare zones, DNS records, [zone settings](https://developers.cloudflare.com/api/resources/zones/subresources/settings/), optional [Argo Smart Routing](https://developers.cloudflare.com/argo-smart-routing/), [Tiered Caching](https://developers.cloudflare.com/cache/about/tiered-cache/), and [Rulesets](https://developers.cloudflare.com/ruleset-engine/about/rulesets/).

This module supports:

- Creating or using an existing Cloudflare zone.
- Managing multiple DNS records, including:
  - Full control over TTL, proxying, priority, and comments.
- Managing zone settings (e.g., SSL mode, Always Use HTTPS, HSTS).
- Enabling and configuring Cloudflare Argo features:
  - Smart Routing
  - Tiered Caching
- Defining custom Cloudflare Rulesets (e.g., redirect logic, access policies).

## Example

```hcl
module "zone" {
  source  = "rashedobaid/zone/cloudflare"

  # Required Cloudflare account ID
  account_id = "your-cloudflare-account-id"

  # Domain name to create/manage in Cloudflare
  zone = "example.com"

  # Whether to create a new zone or use an existing one
  zone_enabled = true

  # Enable Argo features
  argo_enabled                 = true
  argo_smart_routing_enabled   = true
  argo_tiered_caching_enabled  = true

  # DNS records to manage
  records = [
    {
      name    = "www"
      type    = "A"
      content = "192.0.2.1"
      ttl     = 300
      proxied = true
      comment = "Main website"
    },
    {
      name     = "@"
      type     = "MX"
      content  = "mail.example.com"
      ttl      = 3600
      priority = 10
      comment  = "Mail server"
    }
  ]

  # Zone settings to manage; unset settings are left unmanaged
  zone_settings = {
    always_use_https = "on"
    ssl              = "strict"
    min_tls_version  = "1.2"
    security_header = {
      strict_transport_security = {
        enabled            = true
        include_subdomains = true
        max_age            = 31536000
        nosniff            = true
        preload            = true
      }
    }
  }

  # Optional rulesets to apply
  rulesets = [
    {
      phase = "http_request_dynamic_redirect"
      rules = [
        {
          description = "Redirect example.com to example.net"
          expression  = "http.host eq \"example.com\""
          action      = "redirect"
          action_parameters = {
            from_value = {
              target_url = {
                value = "https://example.net"
              }
              status_code           = 301
              preserve_query_string = true
            }
          }
        }
      ]
    }
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >= 5.5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 5.28.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_argo_smart_routing.default](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/argo_smart_routing) | resource |
| [cloudflare_argo_tiered_caching.default](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/argo_tiered_caching) | resource |
| [cloudflare_dns_record.default](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_ruleset.default](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/ruleset) | resource |
| [cloudflare_zone.default](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone) | resource |
| [cloudflare_zone_setting.default](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_setting) | resource |
| [cloudflare_zones.default](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The Cloudflare account ID associated with the zone. | `string` | n/a | yes |
| <a name="input_argo_enabled"></a> [argo\_enabled](#input\_argo\_enabled) | Whether to enable Cloudflare Argo for the zone. | `bool` | `false` | no |
| <a name="input_argo_smart_routing_enabled"></a> [argo\_smart\_routing\_enabled](#input\_argo\_smart\_routing\_enabled) | Enable smart routing as part of Argo features. | `bool` | `true` | no |
| <a name="input_argo_tiered_caching_enabled"></a> [argo\_tiered\_caching\_enabled](#input\_argo\_tiered\_caching\_enabled) | Enable tiered caching as part of Argo features. | `bool` | `true` | no |
| <a name="input_records"></a> [records](#input\_records) | List of DNS records to be created within the zone. | <pre>list(object({<br/>    name     = string<br/>    type     = string<br/>    ttl      = optional(number, 1)<br/>    content  = optional(string)<br/>    data     = optional(map(any))<br/>    priority = optional(number)<br/>    proxied  = optional(bool)<br/>    comment  = optional(string)<br/>    settings = optional(map(any))<br/>  }))</pre> | `[]` | no |
| <a name="input_rulesets"></a> [rulesets](#input\_rulesets) | List of Rulesets to be created within the zone. | <pre>list(object({<br/>    name        = optional(string, "default")<br/>    phase       = string<br/>    description = optional(string)<br/>    rules = optional(list(object({<br/>      action      = string<br/>      expression  = string<br/>      description = optional(string)<br/>      enabled     = optional(bool)<br/>      ref         = optional(string)<br/>      action_parameters = optional(object({<br/>        id                       = optional(string)<br/>        ruleset                  = optional(string)<br/>        version                  = optional(string)<br/>        phases                   = optional(list(string))<br/>        products                 = optional(list(string))<br/>        host_header              = optional(string)<br/>        status_code              = optional(number)<br/>        content                  = optional(string)<br/>        content_type             = optional(string)<br/>        polish                   = optional(string)<br/>        security_level           = optional(string)<br/>        ssl                      = optional(string)<br/>        automatic_https_rewrites = optional(bool)<br/>        mirage                   = optional(bool)<br/>        rocket_loader            = optional(bool)<br/>        bic                      = optional(bool)<br/>        hotlink_protection       = optional(bool)<br/>        cache                    = optional(bool)<br/>        origin_cache_control     = optional(bool)<br/>        browser_ttl = optional(object({<br/>          mode    = string<br/>          default = optional(number)<br/>        }))<br/>        edge_ttl = optional(object({<br/>          mode    = string<br/>          default = optional(number)<br/>          status_code_ttl = optional(list(object({<br/>            value       = number<br/>            status_code = optional(number)<br/>            status_code_range = optional(object({<br/>              from = optional(number)<br/>              to   = optional(number)<br/>            }))<br/>          })))<br/>        }))<br/>        cache_key = optional(object({<br/>          ignore_query_strings_order = optional(bool)<br/>          cache_by_device_type       = optional(bool)<br/>          cache_deception_armor      = optional(bool)<br/>          custom_key = optional(object({<br/>            cookie = optional(object({<br/>              include        = optional(list(string))<br/>              check_presence = optional(list(string))<br/>            }))<br/>            header = optional(object({<br/>              include        = optional(list(string))<br/>              check_presence = optional(list(string))<br/>              exclude_origin = optional(bool)<br/>            }))<br/>            host = optional(object({<br/>              resolved = optional(bool)<br/>            }))<br/>            user = optional(object({<br/>              device_type = optional(bool)<br/>              geo         = optional(bool)<br/>              lang        = optional(bool)<br/>            }))<br/>            query_string = optional(object({<br/>              include = optional(object({<br/>                all  = optional(bool)<br/>                list = optional(list(string))<br/>              }))<br/>              exclude = optional(object({<br/>                all  = optional(bool)<br/>                list = optional(list(string))<br/>              }))<br/>            }))<br/>          }))<br/>        }))<br/>        serve_stale = optional(object({<br/>          disable_stale_while_updating = optional(bool)<br/>        }))<br/>        headers = optional(map(object({<br/>          operation  = string<br/>          value      = optional(string)<br/>          expression = optional(string)<br/>        })))<br/>        from_value = optional(object({<br/>          status_code           = optional(number)<br/>          preserve_query_string = optional(bool)<br/>          target_url = optional(object({<br/>            value      = optional(string)<br/>            expression = optional(string)<br/>          }))<br/>        }))<br/>        uri = optional(object({<br/>          path = optional(object({<br/>            value      = optional(string)<br/>            expression = optional(string)<br/>          }))<br/>          query = optional(object({<br/>            value      = optional(string)<br/>            expression = optional(string)<br/>          }))<br/>        }))<br/>        overrides = optional(object({<br/>          action            = optional(string)<br/>          enabled           = optional(bool)<br/>          sensitivity_level = optional(string)<br/>          categories = optional(list(object({<br/>            category          = string<br/>            action            = optional(string)<br/>            enabled           = optional(bool)<br/>            sensitivity_level = optional(string)<br/>          })))<br/>          rules = optional(list(object({<br/>            id                = string<br/>            action            = optional(string)<br/>            enabled           = optional(bool)<br/>            score_threshold   = optional(number)<br/>            sensitivity_level = optional(string)<br/>          })))<br/>        }))<br/>      }))<br/>      logging = optional(object({<br/>        enabled = optional(bool)<br/>      }))<br/>      ratelimit = optional(object({<br/>        characteristics     = list(string)<br/>        period              = number<br/>        requests_per_period = optional(number)<br/>        mitigation_timeout  = optional(number)<br/>        counting_expression = optional(string)<br/>        requests_to_origin  = optional(bool)<br/>        score_per_period    = optional(number)<br/>      }))<br/>      exposed_credential_check = optional(object({<br/>        username_expression = string<br/>        password_expression = string<br/>      }))<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_type"></a> [type](#input\_type) | Type of zone: 'full' for Cloudflare-managed DNS, or 'partial' for CNAME setup. | `string` | `"full"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The domain name of the Cloudflare zone (e.g., example.com). | `string` | n/a | yes |
| <a name="input_zone_enabled"></a> [zone\_enabled](#input\_zone\_enabled) | Determines whether to create a new DNS zone. If set to false, uses an existing zone. | `bool` | `true` | no |
| <a name="input_zone_settings"></a> [zone\_settings](#input\_zone\_settings) | Zone settings to manage, keyed by Cloudflare setting ID; unset settings are left unmanaged. `zero_rtt` maps to the `0rtt` setting, and `ssl_recommender` is sent as the resource's `enabled` attribute. | <pre>object({<br/>    zero_rtt                        = optional(string)<br/>    advanced_ddos                   = optional(string)<br/>    always_online                   = optional(string)<br/>    always_use_https                = optional(string)<br/>    automatic_https_rewrites        = optional(string)<br/>    brotli                          = optional(string)<br/>    browser_check                   = optional(string)<br/>    content_converter               = optional(string)<br/>    development_mode                = optional(string)<br/>    early_hints                     = optional(string)<br/>    email_obfuscation               = optional(string)<br/>    hotlink_protection              = optional(string)<br/>    http2                           = optional(string)<br/>    http3                           = optional(string)<br/>    ip_geolocation                  = optional(string)<br/>    ipv6                            = optional(string)<br/>    mirage                          = optional(string)<br/>    opportunistic_encryption        = optional(string)<br/>    opportunistic_onion             = optional(string)<br/>    orange_to_orange                = optional(string)<br/>    origin_error_page_pass_thru     = optional(string)<br/>    pre_render                      = optional(string)<br/>    prefetch_preload                = optional(string)<br/>    privacy_pass                    = optional(string)<br/>    redirects_for_ai_training       = optional(string)<br/>    replace_insecure_js             = optional(string)<br/>    response_buffering              = optional(string)<br/>    rocket_loader                   = optional(string)<br/>    search_for_agents               = optional(string)<br/>    server_side_exclude             = optional(string)<br/>    sha1_support                    = optional(string)<br/>    sort_query_string_for_cache     = optional(string)<br/>    tls_1_2_only                    = optional(string)<br/>    tls_client_auth                 = optional(string)<br/>    true_client_ip_header           = optional(string)<br/>    waf                             = optional(string)<br/>    webmcp_enabled                  = optional(string)<br/>    webp                            = optional(string)<br/>    websockets                      = optional(string)<br/>    cache_level                     = optional(string)<br/>    cname_flattening                = optional(string)<br/>    h2_prioritization               = optional(string)<br/>    image_resizing                  = optional(string)<br/>    min_tls_version                 = optional(string)<br/>    origin_max_http_version         = optional(string)<br/>    polish                          = optional(string)<br/>    pseudo_ipv4                     = optional(string)<br/>    security_level                  = optional(string)<br/>    ssl                             = optional(string)<br/>    tls_1_3                         = optional(string)<br/>    transformations                 = optional(string)<br/>    transformations_allowed_origins = optional(string)<br/>    webmcp_mcp_url                  = optional(string)<br/>    webmcp_packs                    = optional(string)<br/>    browser_cache_ttl               = optional(number)<br/>    challenge_ttl                   = optional(number)<br/>    edge_cache_ttl                  = optional(number)<br/>    max_upload                      = optional(number)<br/>    origin_h2_max_streams           = optional(number)<br/>    proxy_read_timeout              = optional(number)<br/>    ciphers                         = optional(list(string))<br/>    ssl_recommender                 = optional(bool)<br/>    aegis = optional(object({<br/>      enabled = bool<br/>      pool_id = string<br/>    }))<br/>    automatic_platform_optimization = optional(object({<br/>      cache_by_device_type = bool<br/>      cf                   = bool<br/>      enabled              = bool<br/>      hostnames            = list(string)<br/>      wordpress            = bool<br/>      wp_plugin            = bool<br/>    }))<br/>    nel = optional(object({<br/>      enabled = bool<br/>    }))<br/>    security_header = optional(object({<br/>      strict_transport_security = object({<br/>        enabled            = optional(bool, false)<br/>        include_subdomains = optional(bool, false)<br/>        max_age            = optional(number, 0)<br/>        nosniff            = optional(bool, false)<br/>        preload            = optional(bool, false)<br/>      })<br/>    }))<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the Cloudflare zone. |
| <a name="output_meta_phishing_detected"></a> [meta\_phishing\_detected](#output\_meta\_phishing\_detected) | Indicates whether phishing content has been detected on the zone. |
| <a name="output_name_servers"></a> [name\_servers](#output\_name\_servers) | List of Cloudflare-assigned name servers. Only populated for zones using full DNS setup. |
| <a name="output_record_key_to_id"></a> [record\_key\_to\_id](#output\_record\_key\_to\_id) | Map of record keys (name-type-content) to record IDs. |
| <a name="output_ruleset_ids"></a> [ruleset\_ids](#output\_ruleset\_ids) | Map of ruleset phases to their corresponding IDs. |
| <a name="output_status"></a> [status](#output\_status) | Current status of the zone (e.g., 'active', 'pending'). |
| <a name="output_type"></a> [type](#output\_type) | The zone type, indicating the plan or configuration applied (e.g., 'full' or 'partial'). |
| <a name="output_vanity_name_servers"></a> [vanity\_name\_servers](#output\_vanity\_name\_servers) | List of custom vanity name servers assigned to the zone, if configured. |
| <a name="output_verification_key"></a> [verification\_key](#output\_verification\_key) | TXT record value used to verify domain ownership. Applicable only for zones of type 'partial'. |
| <a name="output_zone_setting_values"></a> [zone\_setting\_values](#output\_zone\_setting\_values) | Map of managed zone setting IDs to their applied values. |
<!-- END_TF_DOCS -->

## Authors

Module is maintained by [Rashed Obaid](https://github.com/rashedobaid).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/rashedobaid/terraform-cloudflare-zone/tree/main/LICENSE) for full details.
