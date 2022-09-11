terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.78.1"
    }
  }
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "sf-test-eugene"
    region     = "ru-central1-a"
    key        = "issue1/lemp.tfstate"
    access_key = "YCAJEbA_y6J9CETeQPgx_r_P9"
    secret_key = "YCP6kcAJtj-cGmKw16A428lrFs7vkRYBLnAevFIT"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
provider "yandex" {
  token     = "y0_AgAAAAABga1xAATuwQAAAADORS9MjNZ6-eaDR7-pf8CQWjfEsBkux3g"
  cloud_id  = "b1g8rocvglp73db7m6nj"
  folder_id = "b1gpp42islv8uuj99dr0"
  zone      = "ru-central1-a"
}

data "yandex_lb_network_load_balancer" "nlb-image" {
  network_load_balancer_id = "nlb-ll"
}

resource "yandex_lb_network_load_balancer" "nlb-ll-1" {
  name = "ll-network-load-balancer"

  listener {
    name = "listn"
    port = 80
    target_port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "enp5cpecofds620smq4r"

    healthcheck {
      name = "listn"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

data "yandex_lb_target_group" "nlb-tg" {
  target_group_id = "lamp-lemp-group"
}

resource "yandex_lb_target_group" "lamp-lemp" {
  name      = "lamp-lemp-tg"

  target {
    subnet_id = "e9b5ltalpr1mcui58ulc"
    address   = "192.168.10.19"
  }

  target {
    subnet_id = "e2l9an5fv9alom4rninu"
    address   = "192.168.11.33"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}

module "ya_instance_1" {
  source                = "./modules/instance"
  instance_family_image = "lemp"
  vpc_subnet_id         = yandex_vpc_subnet.subnet-1.id
}

module "ya_instance_2" {
  source                = "./modules/instance"
  instance_family_image = "lamp"
  vpc_subnet_id         = yandex_vpc_subnet.subnet-2.id
}