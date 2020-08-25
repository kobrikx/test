variable "env" {
  // We don't have adefault on purpose, so we don't accidentially deploy to a wrong default env
}

variable "names" {
  type = set(string)
}

variable "default_value" {
  default = "-"
}

variable "app_name" {
  default = ""
}
