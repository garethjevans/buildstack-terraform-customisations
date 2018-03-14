output "db-instance-name" {
  value = "${google_sql_database_instance.db-instance.name}"
}

output "db-instance-ip" {
  value = "${google_sql_database_instance.db-instance.ip_address.0.ip_address}"
}

output "gerrit-password" {
  value = "${random_string.gerrit-password.result}"
}

output "sonar-password" {
  value = "${random_string.sonar-password.result}"
}
