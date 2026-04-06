locals {
  rulesets = { for rs in var.rulesets : "${lookup(rs, "name", "default")}_${rs.phase}" => rs }
}

resource "cloudflare_ruleset" "default" {
  for_each = local.rulesets

  zone_id = local.zone_id
  kind    = "zone"
  name    = each.value.name
  phase   = each.value.phase
  rules   = lookup(each.value, "rules", [])
}
