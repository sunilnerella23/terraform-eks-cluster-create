resource "aws_lb" "load_balancer" {
  name               = var.lb_name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  subnets            = var.subnets
  security_groups    = var.security_groups

  enable_deletion_protection = var.delete_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  tags = var.tags
}

resource "aws_lb_target_group" "target_group" {
  for_each = var.target_groups
  name     = each.value.name
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = each.value.vpc_id
}


resource "aws_lb_listener" "listener" {
  for_each = var.listeners
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "${each.value.port}"
  protocol          = each.value.protocol
  certificate_arn   = try(each.value.certificate_arn, null)

  default_action {
    type             = try(each.value.action_type, "forward")
    target_group_arn = aws_lb_target_group.target_group[each.value.target_group].arn
  }
}
