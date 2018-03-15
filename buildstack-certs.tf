variable "certificate" {
  type = "string"
}

variable "key" {
  type = "string"
}

resource "google_compute_ssl_certificate" "buildstack-cert" {
  name = "buildstack"
  name_prefix = "${var.env_id}"
  description = "user provided ssl private key / ssl certificate pair"
  private_key = "${var.key}"
  certificate = "${var.certificate}"

  lifecycle {
    create_before_destroy = true
  }
}
