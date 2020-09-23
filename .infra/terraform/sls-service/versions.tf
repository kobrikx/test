terraform {
  required_version = "~> 0.12.0"
}

variable "volume" {
  default = {}
}

variable "efs_mount_point" {
  default = "/mnt/efs"
}
