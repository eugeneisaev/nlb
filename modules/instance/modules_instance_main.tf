terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.78.1"
    }
  }
}
provider "yandex" {
  token     = "y0_AgAAAAABga1xAATuwQAAAADORS9MjNZ6-eaDR7-pf8CQWjfEsBkux3g"
  cloud_id  = "b1g8rocvglp73db7m6nj"
  folder_id = "b1gpp42islv8uuj99dr0"
  zone      = "ru-central1-b"
}

data "yandex_compute_image" "my_image" {
  family = var.instance_family_image
}

resource "yandex_compute_instance" "vm" {
  name = "terraform-${var.instance_family_image}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_image.id
    }
  }

  network_interface {
    subnet_id = var.vpc_subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}