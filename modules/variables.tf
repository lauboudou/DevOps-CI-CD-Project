
# ajout variable nom de l'image
variable "image_name" {
  description = "This is a variable of image name"
  type        = string
  default     = "ubuntu-ssh"
}

# ajout variable nom du contenaire ubuntu-ssh de l'installation des applications
variable "container_name1" {
  description = "This is a variable of Docker container"
  type        = string
  default     = "vm-ubuntu-install"
}


# ajout variable nom du contenaire ubuntu-ssh des applications
variable "container_name2" {
  description = "This is a variable of Docker container"
  type        = string
  default     = "vm-ubuntu-devops"
}
