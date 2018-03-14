resource "google_sql_database_instance" "db-instance" {
  region = "${var.region}"
  project = "${var.project_id}"

  settings {
    tier = "db-n1-standard-2"
    disk_autoresize = "true"

    ip_configuration {
      ipv4_enabled = "true"

      authorized_networks = [
		authorized_network_0 = "${module.terraform-gcp-natgateway.nat-gateway-ips["0"]}"
      ]

    }

    backup_configuration {
      binary_log_enabled = "true"
      enabled = "true"
      start_time = "02:00"
    }

  }
}

resource "google_sql_database_instance" "db-failover" {
  region = "${var.region}"
  project = "${var.project_id}"
  depends_on = ["google_sql_database_instance.db-instance"]

  master_instance_name = "${google_sql_database_instance.db-instance.name}"
  replica_configuration {
    failover_target = "true"
  }

  settings {
    tier = "db-n1-standard-2"
    disk_autoresize = "true"

    ip_configuration {
      ipv4_enabled = "true"

      authorized_networks = [
		authorized_network_0 = "${module.terraform-gcp-natgateway.nat-gateway-ips["0"]}"
      ]
    }

  }
}

