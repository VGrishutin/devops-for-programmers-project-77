
# создаем alb
resource "yandex_alb_target_group" "alb-tg" {
  name                   = "alb-tg"

  target {
    subnet_id   = yandex_vpc_subnet.private-subnet.id
    ip_address  = yandex_compute_instance.vm-1.network_interface.0.ip_address
  }

  target {
    subnet_id   = yandex_vpc_subnet.private-subnet.id
    ip_address  = yandex_compute_instance.vm-2.network_interface.0.ip_address
  }
}

# Создание группу бэкендов

resource "yandex_alb_backend_group" "alb-bg" {
  name                     = "alb-bg"

  http_backend {
    name                   = "alb-backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = [yandex_alb_target_group.alb-tg.id]
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthcheck_port     = 80
      http_healthcheck {
        path               = "/"
      }
    }
  }
}


# Создание HTTP-роутера

resource "yandex_alb_http_router" "alb-router" {
  name          = "alb-router"
}

resource "yandex_alb_virtual_host" "alb-host" {
  name                    = "alb-host"
  authority               = [
                              "hexlet-p2.mexaho.online",
                              yandex_vpc_address.addr_lb.external_ipv4_address[0].address
                            ]
  http_router_id          = yandex_alb_http_router.alb-router.id
  route {
    name                  = "alb-route"
    http_route {
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.alb-bg.id
        timeout           = "60s"
      }
    }
  }
}    

# Импорт TLS-сертификат сайта

resource "yandex_cm_certificate" "imported-cert" {
  name    = "imported-cert"

  self_managed {
    certificate = "${file("./certificate/certificate.crt")}"
    private_key = "${file("./certificate//mexaho.online.key")}"
  }
}

# Создание L7-балансировщика

resource "yandex_alb_load_balancer" "alb-balancer" {
  name        = "alb-balancer"
  network_id  = yandex_vpc_network.network-1.id
  security_group_ids = [yandex_vpc_security_group.sg-lb.id]

  allocation_policy {
    location {
      zone_id   = var.yc_zone
      subnet_id = yandex_vpc_subnet.public-subnet.id
    }
  }

  listener {
    name = "listener-http"
    endpoint {
      address {
        external_ipv4_address {
          address = yandex_vpc_address.addr_lb.external_ipv4_address[0].address
        }
      }
    ports = [ 80 ]
    }
    http {
      redirects {
        http_to_https = true
      }
    }
  }

  listener {
    name = "https"
    endpoint {
      address {
        external_ipv4_address {
          address = yandex_vpc_address.addr_lb.external_ipv4_address[0].address
        }
      }
      ports = [ 443 ]
    }
    tls {
      default_handler {
        http_handler {
          http_router_id = yandex_alb_http_router.alb-router.id
        }
        certificate_ids = [yandex_cm_certificate.imported-cert.id]
      }
      # sni_handler {
      #   name         = "mysite-sni"
      #   server_names = ["hexlet-p2.mexaho.online"]
      #   handler {
      #     http_handler {
      #       http_router_id = yandex_alb_http_router.alb-router.id
      #     }
      #     certificate_ids = [yandex_cm_certificate.imported-cert.id]
      #   }
      # }
    }
  }
}

# # Создание DNS-зоны

# resource "yandex_dns_zone" "alb-zone" {
#   name        = "alb-zone"
#   description = "Public zone"
#   zone        = "hexlet-p2.mexaho.online."
#   public      = true
# }

# # Создание ресурсной записи в DNS-зоне

# resource "yandex_dns_recordset" "alb-record" {
#   name    = "hexlet-p2.mexaho.online."
#   zone_id = yandex_dns_zone.alb-zone.id
#   ttl     = 600
#   type    = "A"
#   data    = [yandex_alb_load_balancer.alb-balancer.listener[0].endpoint[0].address[0].external_ipv4_address[0].address]
# 