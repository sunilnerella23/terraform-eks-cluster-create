resource "aws_ecr_repository" "ecr" {
  for_each = var.repositories
  name     = each.key
}

data "aws_iam_policy_document" "ecr_cross_account_policy" {
  for_each = var.repositories
  statement {
    sid    = "AllowCrossAccountPull"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = try(each.value.allowed_accounts, var.allowed_accounts, local.allowed_accounts)
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
  }
}

resource "aws_ecr_repository_policy" "ecr_cross_account_policy" {
  for_each   = var.repositories
  repository = aws_ecr_repository.ecr[each.key].name
  policy     = data.aws_iam_policy_document.ecr_cross_account_policy[each.key].json
}
