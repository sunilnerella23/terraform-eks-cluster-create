variable "lb_name" {
    type = string
}

variable "internal" {
  type = bool
  default = true
}

variable "load_balancer_type" {
  type = string
  default = "network"
}

variable "subnets" {
  type = list(string)
}

variable "delete_protection" {
  type = bool
  default = false
}

variable "tags" {
  default = {}
}

variable "target_groups" {
  default = {}
}

variable "security_groups" {
  default = []
  type = list(string)
}

variable "listeners" {
  type = any
  default = {}
}

variable "enable_cross_zone_load_balancing" {
  type = bool
  default = true
}