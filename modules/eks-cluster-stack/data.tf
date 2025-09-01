data "aws_caller_identity" "current" {}

data "terraform_remote_state" "mgmt_cluster" {
  count   = var.register_as_spoke ? 1 : 0
  backend = "s3"

  config = {
    bucket = var.management_cluster_state.bucket
    region = try(var.management_cluster_state.region, "us-east-1")
    key    = var.management_cluster_state.key
  }
}
