resource "google_compute_global_address" "jenkins-address" {
  name = "${var.env_id}-jenkins"
}

resource "google_compute_global_forwarding_rule" "jenkins-http-forwarding-rule" {
  name       = "${var.env_id}-jenkins-http"
  ip_address = "${google_compute_global_address.jenkins-address.address}"
  target     = "${google_compute_target_http_proxy.jenkins-http-lb-proxy.self_link}"
  port_range = "80"
}

//resource "google_compute_global_forwarding_rule" "jenkins-https-forwarding-rule" {
//  name       = "${var.env_id}-jenkins-https"
//  ip_address = "${google_compute_global_address.jenkins-address.address}"
//  target     = "${google_compute_target_https_proxy.jenkins-https-lb-proxy.self_link}"
//  port_range = "443"
//}

resource "google_compute_target_http_proxy" "jenkins-http-lb-proxy" {
  name        = "${var.env_id}-http-proxy"
  description = "really a load balancer but listed as an http proxy"
  url_map     = "${google_compute_url_map.jenkins-https-lb-url-map.self_link}"
}

//resource "google_compute_target_https_proxy" "jenkins-https-lb-proxy" {
//  name             = "${var.env_id}-https-proxy"
//  description      = "really a load balancer but listed as an https proxy"
//  url_map          = "${google_compute_url_map.jenkins-https-lb-url-map.self_link}"
//  ssl_certificates = ["${google_compute_ssl_certificate.jenkins-cert.self_link}"]
//}

//resource "google_compute_ssl_certificate" "jenkins-cert" {
//  name_prefix = "${var.env_id}"
//  description = "user provided ssl private key / ssl certificate pair"
//  private_key = "${var.ssl_certificate_private_key}"
//  certificate = "${var.ssl_certificate}"

//  lifecycle {
//    create_before_destroy = true
//  }
//}

resource "google_compute_url_map" "jenkins-https-lb-url-map" {
  name = "${var.env_id}-jenkins-http"
  default_service = "${google_compute_backend_service.router-lb-backend-service.self_link}"
}

resource "google_compute_health_check" "jenkins-public-health-check" {
  name = "${var.env_id}-jenkins-public"
  http_health_check {
    port         = 8080
    request_path = "/login"
  }
}

resource "google_compute_http_health_check" "jenkins-public-health-check" {
  name         = "${var.env_id}-jenkins"
  port         = 8080
  request_path = "/login"
}

resource "google_compute_firewall" "jenkins-health-check" {
  name       = "${var.env_id}-jenkins-health-check"
  depends_on = ["google_compute_network.bbl-network"]
  network    = "${google_compute_network.bbl-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["8080", "80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["${google_compute_backend_service.router-lb-backend-service.name}"]
}


resource "google_compute_instance_group" "router-lb-0" {
  name        = "${var.env_id}-router-lb-0-europe-west1-b"
  description = "terraform generated instance group that is multi-zone for https loadbalancing"
  zone        = "europe-west1-b"

  named_port {
    name = "http"
    port = "8080"
  }
}

resource "google_compute_instance_group" "router-lb-1" {
  name        = "${var.env_id}-router-lb-1-europe-west1-c"
  description = "terraform generated instance group that is multi-zone for https loadbalancing"
  zone        = "europe-west1-c"

  named_port {
    name = "http"
    port = "8080"
  }
}

resource "google_compute_instance_group" "router-lb-2" {
  name        = "${var.env_id}-router-lb-2-europe-west1-d"
  description = "terraform generated instance group that is multi-zone for https loadbalancing"
  zone        = "europe-west1-d"

  named_port {
    name = "http"
    port = "8080"
  }
}

resource "google_compute_backend_service" "router-lb-backend-service" {
  name        = "${var.env_id}-router-lb"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 900
  enable_cdn  = false

  backend {
    group = "${google_compute_instance_group.router-lb-0.self_link}"
  }

  backend {
    group = "${google_compute_instance_group.router-lb-1.self_link}"
  }

  backend {
    group = "${google_compute_instance_group.router-lb-2.self_link}"
  }

  health_checks = ["${google_compute_health_check.jenkins-public-health-check.self_link}"]
}
