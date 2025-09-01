variable "name" {
    type = string
    default = null
}

variable "description" {
    type = string
    default = null
}

variable "vpc_id" {
    type = string
    default = null
}

variable "ingress_rules" {
    type = any
    default = {}
}

variable "egress_rules" {
    type = any
    default = {}
}

variable "tags" {
  type = any
  default = null
}