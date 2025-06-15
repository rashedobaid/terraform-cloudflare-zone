locals {
  zone_enabled    = var.zone_enabled
  zone_exists     = !var.zone_enabled
  zone_id         = local.zone_enabled ? join("", cloudflare_zone.default[*].id) : (local.zone_exists ? data.cloudflare_zones.default[0].result[0].id : null)
  zone_name       = local.zone_enabled ? cloudflare_zone.default[0].name : (local.zone_exists ? data.cloudflare_zones.default[0].result[0].name : null)
  records_enabled = length(var.records) > 0
  records = local.records_enabled ? {
    for index, record in var.records :
    try(record.key, format("%s-%s-%s", record.name, record.type, record.content)) => record
  } : {}
  records_name = {
    for k, v in local.records : k => (
      v.name == "@" || v.name == local.zone_name
      ) ? local.zone_name : (
      endswith(v.name, ".${local.zone_name}") ? v.name : "${v.name}.${local.zone_name}"
    )
  }
  argo_enabled   = var.argo_enabled
  tiered_caching = local.argo_enabled && var.argo_tiered_caching_enabled ? "on" : "off"
  smart_routing  = local.argo_enabled && var.argo_smart_routing_enabled ? "on" : "off"
}

data "cloudflare_zones" "default" {
  count = local.zone_exists ? 1 : 0

  account = {
    id = var.account_id
  }
  name = var.zone
}

resource "cloudflare_zone" "default" {
  count = local.zone_enabled ? 1 : 0

  account = {
    id = var.account_id
  }
  name = var.zone
  type = var.type
}

resource "cloudflare_dns_record" "default" {
  for_each = { for k, v in local.records : k => v if try(v.managed, true) }

  zone_id  = local.zone_id
  name     = local.records_name[each.key]
  type     = each.value.type
  content  = each.value.content
  ttl      = lookup(each.value, "ttl", 1)
  priority = lookup(each.value, "priority", null)
  proxied  = lookup(each.value, "proxied", false)
  comment  = lookup(each.value, "comment", null)
}

# The DNS record resource when we are **not** managing the content, such as when using DDNS or Cloudflare API:
resource "cloudflare_dns_record" "unmanaged" {
  for_each = { for k, v in local.records : k => v if !try(v.managed, true) }

  zone_id  = local.zone_id
  name     = local.records_name[each.key]
  type     = each.value.type
  content  = each.value.content
  ttl      = lookup(each.value, "ttl", 1)
  priority = lookup(each.value, "priority", null)
  proxied  = lookup(each.value, "proxied", false)
  comment  = lookup(each.value, "comment", null)

  lifecycle {
    ignore_changes = [content]
  }
}

resource "cloudflare_argo_smart_routing" "default" {
  count = local.argo_enabled ? 1 : 0

  zone_id = local.zone_id
  value   = local.smart_routing
}

resource "cloudflare_argo_tiered_caching" "default" {
  count = local.argo_enabled ? 1 : 0

  zone_id = local.zone_id
  value   = local.tiered_caching
}
