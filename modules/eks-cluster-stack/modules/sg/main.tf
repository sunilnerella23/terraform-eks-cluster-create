resource "aws_security_group" "security_group" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "ingress_rules" {
  for_each                 = var.ingress_rules
  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = try(each.value.cidr_blocks, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, null)
  security_group_id        = aws_security_group.security_group.id
}

resource "aws_security_group_rule" "egress_rules" {
  for_each                 = var.egress_rules
  type                     = "egress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
  security_group_id        = aws_security_group.security_group.id
}

