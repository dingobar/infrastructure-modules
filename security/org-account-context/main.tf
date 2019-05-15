provider "aws" {
  version = "~> 1.60.0"
  region  = "${var.aws_region}"

  # Assume role in Master account
  assume_role {
    role_arn = "arn:aws:iam::${var.master_account_id}:role/${var.prime_role_name}"
  }
}

provider "aws" {
  version = "~> 1.60.0"
  region  = "${var.aws_region}"
  alias   = "core"
}

provider "aws" {
  version = "~> 1.60.0"
  region  = "${var.aws_region}"

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = "${var.access_key_master}"
  secret_key = "${var.secret_key_master}"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = "${module.org_account.org_role_arn}"
  }

  alias = "workload"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend          "s3"             {}
  required_version = "~> 0.11.7"
}

module "iam_policies" {
  source                            = "../../_sub/security/iam-policies"
  iam_role_trusted_account_root_arn = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
}

module "org_account" {
  source        = "../../_sub/security/org-account"
  name          = "${var.name}"
  org_role_name = "${var.org_role_name}"
  email         = "${var.email}"
}

module "iam_account_alias" {
  source        = "../../_sub/security/iam-account-alias"
  account_alias = "${module.org_account.name}"

  providers = {
    aws = "aws.workload"
  }
}

module "iam_idp" {
  source        = "../../_sub/security/iam-idp"
  provider_name = "ADFS"
  adfs_fqdn     = "${var.adfs_fqdn}"

  providers = {
    aws = "aws.workload"
  }
}

module "iam_role_capability" {
  source = "../../_sub/security/iam-role"
  role_name = "Capability"
  role_description = ""
  assume_role_policy = "${module.iam_idp.adfs_assume_policy}"
  role_policy_name = "Admin"
  role_policy_document = "${module.iam_policies.admin}"

  providers = {
    aws = "aws.workload"
  }
}

locals {
  account_created_payload = <<EOF
{"contextId":"${var.context_id}","accountId":"${module.org_account.id}","roleArn":"${module.iam_role_capability.arn}","roleEmail":"${module.org_account.email}"}EOF
}

module "kafka_produce_account_created" {
  source = "../../_sub/misc/kafka-message"
  event_name = "aws_context_account_created"
  message_version = "1"
  correlation_id = "${var.correlation_id}"
  sender = "org-account-context created by terraform"
  payload = "${local.account_created_payload}"
  key = "johnjohnson"
  broker = "${var.kafka_broker}"
  topic = "sre-test"
  username = "${var.kafka_username}"
  password = "${var.kafka_password}"
}