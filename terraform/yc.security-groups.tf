# Создание групп безопасности
resource "yandex_vpc_security_group" "sg-external" {
  name        = "sg-external"
  network_id  = yandex_vpc_network.network-1.id
}


resource "yandex_vpc_security_group" "sg-nat" {
  name        = "sg-nat"
  network_id  = yandex_vpc_network.network-1.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 65535
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
      protocol          = "ANY"
      description       = "vms"
      from_port = 0
      to_port = 65535
      security_group_id = yandex_vpc_security_group.sg-external.id
  }

}

resource "yandex_vpc_security_group" "sg-vms" {
  name        = "sg-vms"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
      protocol          = "TCP"
      description       = "ssh"
      from_port         = 22
      to_port           = 22
      security_group_id = yandex_vpc_security_group.sg-nat.id
  }

  ingress {
      protocol          = "TCP"
      description       = "balancer"
      from_port         = 80
      to_port           = 80
      security_group_id = yandex_vpc_security_group.sg-lb.id
  }

  ingress {
      protocol          = "ANY"
      description       = "from members of the same security group"
      from_port         = 0
      to_port           = 65535
      predefined_target = "self_security_group"
  }

  egress {
      protocol          = "ANY"
      description       = "to members of the same security group"
      from_port         = 0
      to_port           = 65535
      predefined_target = "self_security_group"
    } 

  egress {
      protocol          = "ANY"
      description       = "to anyone"
      v4_cidr_blocks = ["0.0.0.0/0"]
      from_port = 0
      to_port = 65535
    } 
  egress {
      protocol          = "ANY"
      description       = "external"
      security_group_id = yandex_vpc_security_group.sg-external.id
      from_port = 0
      to_port = 65535
    } 
}

resource "yandex_vpc_security_group" "sg-lb" {
  name        = "sg-lb"
  network_id  = yandex_vpc_network.network-1.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 65535
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol          = "TCP"
    description       = "healthchecks"
    predefined_target = "loadbalancer_healthchecks"
    port              = 30080
 }
}
