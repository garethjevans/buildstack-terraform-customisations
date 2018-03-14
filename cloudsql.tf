resource "google_sql_database_instance" "db-instance" {
  region = "${var.region}"
  project = "${var.project_id}"

  settings {
    tier = "db-n1-standard-2"
    disk_autoresize = "true"

    ip_configuration {
      ipv4_enabled = "true"

      authorized_networks = [
        { value = "${module.terraform-gcp-natgateway.nat-gateway-ips["0"]}" }
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
        { value = "${module.terraform-gcp-natgateway.nat-gateway-ips["0"]}" }
      ]
    }

  }
}

resource "google_sql_database" "gerrit_db" {
  name = "gerrit_db"
  instance = "${google_sql_database_instance.db-instance.name}"
  charset = "utf8"
  collation = "utf8_general_ci"
  depends_on = ["google_sql_database_instance.db-instance", "google_sql_database_instance.db-failover"]
}

resource "random_string" "gerrit-password" {
  length = 16
  special = false
}

resource "google_sql_user" "gerrit" {
  name = "gerrit"
  instance = "${google_sql_database_instance.db-instance.name}"
  host = "%"
  password = "${random_string.gerrit-password.result}"
  depends_on = ["google_sql_database_instance.db-instance", "google_sql_database_instance.db-failover"]
}

resource "google_sql_database" "sonar_db" {
  name = "sonar_db"
  instance = "${google_sql_database_instance.db-instance.name}"
  charset = "utf8"
  collation = "utf8_general_ci"
  depends_on = ["google_sql_database_instance.db-instance", "google_sql_database_instance.db-failover"]
}

resource "random_string" "sonar-password" {
  length = 16
  special = false
}

resource "google_sql_user" "sonar" {
  name = "sonar"
  instance = "${google_sql_database_instance.db-instance.name}"
  host = "%"
  password = "${random_string.sonar-password.result}"
  depends_on = ["google_sql_database_instance.db-instance", "google_sql_database_instance.db-failover"]
}
