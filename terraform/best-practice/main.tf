locals {
    account_id        = data.aws_caller_identity.current.account_id
    region            = data.aws_region.current.name
    naming_convention = "${var.project}-${var.env}-${var.service}-${local.region}-${local.account_id}"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
