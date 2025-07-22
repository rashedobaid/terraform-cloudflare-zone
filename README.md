# Terraform Cloudflare Zone

Terraform module that manages Cloudflare zones, DNS records, optional [Argo Smart Routing](https://developers.cloudflare.com/argo-smart-routing/), [Tiered Caching](https://developers.cloudflare.com/cache/about/tiered-cache/), and [Rulesets](https://developers.cloudflare.com/ruleset-engine/about/rulesets/).

This module supports:

- Creating or using an existing Cloudflare zone.
- Managing multiple DNS records, including:
  - Full control over TTL, proxying, priority, and comments.
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
|------|---------|
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >= 5.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 5.5.0 |

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
| [cloudflare_zones.default](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The Cloudflare account ID associated with the zone. | `string` | n/a | yes |
| <a name="input_argo_enabled"></a> [argo\_enabled](#input\_argo\_enabled) | Whether to enable Cloudflare Argo for the zone. | `bool` | `false` | no |
| <a name="input_argo_smart_routing_enabled"></a> [argo\_smart\_routing\_enabled](#input\_argo\_smart\_routing\_enabled) | Enable smart routing as part of Argo features. | `bool` | `true` | no |
| <a name="input_argo_tiered_caching_enabled"></a> [argo\_tiered\_caching\_enabled](#input\_argo\_tiered\_caching\_enabled) | Enable tiered caching as part of Argo features. | `bool` | `true` | no |
| <a name="input_records"></a> [records](#input\_records) | List of DNS records to be created within the zone. | `list(any)` | `[]` | no |
| <a name="input_rulesets"></a> [rulesets](#input\_rulesets) | List of Rulesets to be created within the zone. | `list(any)` | `[]` | no |
| <a name="input_type"></a> [type](#input\_type) | Type of zone: 'full' for Cloudflare-managed DNS, or 'partial' for CNAME setup. | `string` | `"full"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The domain name of the Cloudflare zone (e.g., example.com). | `string` | n/a | yes |
| <a name="input_zone_enabled"></a> [zone\_enabled](#input\_zone\_enabled) | Determines whether to create a new DNS zone. If set to false, uses an existing zone. | `bool` | `true` | no |

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
<!-- END_TF_DOCS -->

## Authors

Module is maintained by [Rashed Obaid](https://github.com/rashedobaid).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/rashedobaid/terraform-cloudflare-zone/tree/main/LICENSE) for full details.
