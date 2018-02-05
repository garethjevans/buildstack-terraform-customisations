module "terraform-gcp-natgateway" {
  source = "github.com/migs/terraform-gcp-natgateway"
  project = "${var.project_id}"
  region = "${var.region}"
  network = "${google_compute_network.bbl-network.name}"
  subnetwork = "${google_compute_subnetwork.bbl-subnet.name}"
  route-tag = "no-ip"
  tags = ["nat", "${var.env_id}-internal"]
  nat-gateway-image = "ubuntu-1604-lts"
}
