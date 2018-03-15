resource "google_dns_managed_zone" "env_dns_zone" {
  name        = "${var.env_id}-zone"
  dns_name    = "${var.env_id}.build.finkit.io."
  description = "DNS zone for the ${var.env_id} environment"
}
