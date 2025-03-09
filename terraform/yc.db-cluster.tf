resource "yandex_mdb_postgresql_cluster" "default" {
  name        = "default-db-cluster"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.network-1.id

  deletion_protection = true

  config {
    version = var.yc_postgresql_version
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-hdd"
      disk_size          = 10
    }
    postgresql_config = {
      max_connections = 100
    }
  }

  maintenance_window {
    type = "WEEKLY"
    day  = "SAT"
    hour = 12
  }

  host {
    zone      = var.yc_zone
    subnet_id = yandex_vpc_subnet.private-subnet.id
    name      = var.db_host_name
  }
}

resource "yandex_mdb_postgresql_user" "default" {
  cluster_id = yandex_mdb_postgresql_cluster.default.id
  name       = var.db_user
  password   = var.db_password

  deletion_protection = true
}

resource "yandex_mdb_postgresql_database" "default" {
  cluster_id = yandex_mdb_postgresql_cluster.default.id
  name       = var.db_name
  owner      = yandex_mdb_postgresql_user.default.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
  depends_on = [yandex_mdb_postgresql_user.default]

  deletion_protection = true
}