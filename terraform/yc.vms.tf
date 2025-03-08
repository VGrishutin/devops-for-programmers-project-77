# Создание ВМ для сайтв
resource "yandex_compute_instance" "vm-1" {
  name        = "vm-1"
  platform_id = "standard-v1"
  zone        = var.yc_zone
  folder_id   = var.yc_folder_id
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk_1.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-subnet.id
    security_group_ids = [ 
      yandex_vpc_security_group.sg-vms.id,
      yandex_vpc_security_group.sg-external.id,
     ]
    nat                = false
    ip_address         = "192.168.2.10"
  }

  metadata = {
    user-data          = "${file("./yc.user-data-vm.yml")}"
  }

}

resource "yandex_compute_instance" "vm-2" {
  name        = "vm-2"
  platform_id = "standard-v1"
  zone        = var.yc_zone
  folder_id   = var.yc_folder_id
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk_2.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-subnet.id
    security_group_ids = [ 
      yandex_vpc_security_group.sg-vms.id,
      yandex_vpc_security_group.sg-external.id,
     ]
    nat                = false
    ip_address         = "192.168.2.11"
  }

  metadata = {
    user-data          = "${file("./yc.user-data-vm.yml")}"
  }

}


resource "yandex_compute_image" "vm-instance-ubuntu" {
  name          = "vm-instance-ubuntu"
  source_family = "ubuntu-2204-lts"
}

resource "yandex_compute_disk" "disk_1" {
  name      = "disk-1"
  type      = "network-hdd"
  zone      = var.yc_zone
  size      = "10"
  image_id  =  yandex_compute_image.vm-instance-ubuntu.id

  folder_id = var.yc_folder_id

  labels = {
    environment = "test"
  }
}

resource "yandex_compute_disk" "disk_2" {
  name      = "disk-2"
  type      = "network-hdd"
  zone      = var.yc_zone
  size      = "10"
  image_id  =  yandex_compute_image.vm-instance-ubuntu.id

  folder_id = var.yc_folder_id

  labels = {
    environment = "test"
  }
}


resource "yandex_compute_image" "nat-instance-ubuntu" {
  name          = "nat-instance-ubuntu"
  source_family = "nat-instance-ubuntu"
}

resource "yandex_compute_disk" "boot-disk-nat" {
  name      = "boot-disk-nat"
  type      = "network-hdd"
  zone      = var.yc_zone
  size      = "10"
  image_id  =  yandex_compute_image.nat-instance-ubuntu.id

  folder_id = var.yc_folder_id

  labels = {
    environment = "test"
  }
}


# Создаем NAT инстансе
resource "yandex_compute_instance" "nat-instance" {
  name        = "nat-instance"
  platform_id = "standard-v1"
  zone        = var.yc_zone
  allow_stopping_for_update = true

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-nat.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    security_group_ids = [
      yandex_vpc_security_group.sg-nat.id,
      yandex_vpc_security_group.sg-external.id,
      ]
    nat            = true
    nat_ip_address = yandex_vpc_address.addr_nat.external_ipv4_address[0].address
  }

  metadata = {
    user-data          = "${file("./yc.user-data-nat.yml")}"
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

