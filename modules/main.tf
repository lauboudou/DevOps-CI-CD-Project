
# Pulls the ubuntu-ssh image
resource "docker_image" "ubuntu-ssh" {
  name         = var.image_name
  keep_locally = false
}

# Créer un réseau privé
resource "docker_network" "ntw_project" {
  name = "ntw_devops"
}

resource "docker_container" "ubuntu-ssh-container" {
  count  = 2
  image  = docker_image.ubuntu-ssh.image_id
  name   = count.index < 1 ? "${var.container_name1}" : "${var.container_name2}"
  memory = 2048
  mounts {
    type   = "bind"
    source = "/var/run/docker.sock"
    target = "/var/run/docker.sock"
  }

  ports {
    internal = 22
    external = 6022 + count.index+1
  }

  ports {
    internal = 5000
    external = 5000 + count.index+1
  }

  ports {
    internal = 8080
    external = 8080 + count.index+1
  }

  ports {
    internal = 9000
    external = 9000 + count.index+1
  }

  ports {
    internal = 50000
    external = 50000 + count.index+1
  }

  ports {
    internal = 5432
    external = 5432 + count.index+1
  }

  networks_advanced {
    name = docker_network.ntw_project.name
  }
}