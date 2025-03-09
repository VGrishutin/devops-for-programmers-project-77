# Создание облачной сети

resource "yandex_vpc_network" "network-1" {
  name = "network-1"
}

resource "yandex_vpc_subnet" "public-subnet" {
  name           = "public-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

resource "yandex_vpc_subnet" "private-subnet" {
  name           = "private-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.2.0/24"]
  route_table_id = yandex_vpc_route_table.nat-instance-route.id
}

# Создание статического публичного IP-адреса
resource "yandex_vpc_address" "addr_nat" {
  name                = "addr_nat"
  deletion_protection = "true"

  external_ipv4_address {
    zone_id = var.yc_zone
  }
}

resource "yandex_vpc_address" "addr_lb" {
  name                = "addr_lb"
  deletion_protection = "true"

  external_ipv4_address {
    zone_id = var.yc_zone
  }
}


# Создание таблицы маршрутизации и статического маршрута
resource "yandex_vpc_route_table" "nat-instance-route" {
  name       = "nat-instance-route"
  network_id = yandex_vpc_network.network-1.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-instance.network_interface.0.ip_address
  }
}



