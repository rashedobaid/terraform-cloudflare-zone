locals {
  rulesets = { for rs in var.rulesets : rs.phase => rs }
}

resource "cloudflare_ruleset" "default" {
  for_each = local.rulesets

  zone_id = local.zone_id
  kind    = "zone"
  name    = "default"
  phase   = each.key
  rules   = lookup(each.value, "rules", [])
}