variable "name" {}
variable "env" {}
variable "vpc" {}
variable "parameters" {
  type = map(string)
}
variable "secrets" {
  default = []
}
