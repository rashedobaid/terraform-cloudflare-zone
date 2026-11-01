locals {
  # Attribute names that differ from the Cloudflare setting ID (HCL identifiers can't start with a digit).
  zone_setting_ids = {
    zero_rtt = "0rtt"
  }

  zone_settings = merge(
    {
      for name, value in var.zone_settings :
      lookup(local.zone_setting_ids, name, name) => { value = value, enabled = null }
      if value != null && name != "ssl_recommender"
    },
    # The API toggles ssl_recommender via `enabled`; the provider still requires `value`.
    var.zone_settings.ssl_recommender == null ? {} : {
      ssl_recommender = {
        value   = var.zone_settings.ssl_recommender ? "on" : "off"
        enabled = var.zone_settings.ssl_recommender
      }
    },
  )
}

resource "cloudflare_zone_setting" "default" {
  for_each = local.zone_settings

  zone_id    = local.zone_id
  setting_id = each.key
  value      = each.value.value
  enabled    = each.value.enabled
}
