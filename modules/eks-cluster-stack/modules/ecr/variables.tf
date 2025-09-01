variable "repositories" {
    type = any
}
variable "allowed_accounts" {
    type = list(string)
    default = null
}