# AWS Control Tower Account Factory for Terraform (AFT)
A Control Tower Workshop for Account Factory for Terraform (AFT)

## :question: A question asked from the first session :question:
### When you configure your landing zone for new Regions, AWS Control Tower detective controls adhere to the following rules:

- [You can’t apply new detective controls to existing OUs containing accounts that are not updated. When you’ve configured your AWS Control Tower landing zone into a new Region (by updating your landing zone), you must update existing accounts in your existing OUs before you can enable new detective controls on those OUs and accounts.](https://docs.aws.amazon.com/controltower/latest/userguide/region-how.html#:~:text=You%20can%E2%80%99t%20apply,OUs%20and%20accounts.)

#### Replication:
<img width="600" alt="image" src="https://github.com/aws-6w8hnx/ct-workshop-aft/assets/104741984/32e19305-2a05-416a-8807-101001e34234">

When enabling `detective` Controls (in All controls -> Search for `Behavior = Detective` -> select a control and enable it for the `cfn` OU), you will see the Error Message below:  
<img width="600" alt="image" src="https://github.com/aws-6w8hnx/ct-workshop-aft/assets/104741984/061df152-5167-4049-bbef-326ac88c86f0">

---
## Introduce to Terraform

### 1. How to create a resource using Terraform
1. Create a s3 bucket:
```terraform
locals {
    account_id = data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket" "aft_workshop_bucket" {
  bucket = "aft_workshop-bucket-${local.account_id}"
  force_destroy = true
}
```

2. Enable s3 versioning, add the below:
```terraform
resource "aws_s3_bucket_versioning" "aft_workshop_bucket_versioning" {
  bucket = aws_s3_bucket.aft_workshop_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

3. Enable server side encryption:
```terraform
resource "aws_kms_key" "aft_workshop_bucket_kms_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aft_workshop_bucket_sse" {
  bucket = aws_s3_bucket.aft_workshop_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.aft_workshop_bucket_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
```
  
4. Wrap up:
```terraform
locals {
    account_id = data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket" "aft_workshop_bucket" {
  bucket = "aft_workshop-bucket-${local.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "aft_workshop_bucket_versioning" {
  bucket = aws_s3_bucket.aft_workshop_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "aft_workshop_bucket_kms_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aft_workshop_bucket_sse" {
  bucket = aws_s3_bucket.aft_workshop_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.aft_workshop_bucket_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
```

#### Two examples:
* A bad example: https://github.com/aws-6w8hnx/controltower-workshop-aft/tree/main/terraform/a-bad-example
* best practice: https://github.com/aws-6w8hnx/controltower-workshop-aft/tree/main/terraform/best-practice


### 2. Terraform Modules

* Simple module: https://github.com/aws-6w8hnx/controltower-workshop-aft/tree/main/terraform/use-a-module

### 3. Terraform state
Terraform must store state about your managed infrastructure and configuration. This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures.

* A part of tfstate file sample:
```json
{
  "version": 4,
  "terraform_version": "1.4.5",
  "serial": 24,
  "lineage": "4f64e350-d040-e39b-0ed9-68db4e3f3e1d",
  "outputs": {},
  "resources": [
...
    {
      "mode": "managed",
      "type": "aws_kms_key",
      "name": "aft_workshop_bucket_kms_key",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "arn": "arn:aws:kms:us-east-1:257063532661:key/cd03466d-ce57-4ca7-9909-1714bf26b164",
            "bypass_policy_lockout_safety_check": false,
            "custom_key_store_id": "",
            "customer_master_key_spec": "SYMMETRIC_DEFAULT",
            "deletion_window_in_days": 10,
            "description": "This key is used to encrypt bucket objects",
            "enable_key_rotation": false,
            "id": "cd03466d-ce57-4ca7-9909-1714bf26b164",
            "is_enabled": true,
            "key_id": "cd03466d-ce57-4ca7-9909-1714bf26b164",
            "key_usage": "ENCRYPT_DECRYPT",
            "multi_region": false,
            "policy": "{\"Id\":\"key-default-1\",\"Statement\":[{\"Action\":\"kms:*\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::257063532661:root\"},\"Resource\":\"*\",\"Sid\":\"Enable IAM User Permissions\"}],\"Version\":\"2012-10-17\"}",
            "tags": {},
            "tags_all": {}
          },
          "sensitive_attributes": [],
          "private": "bnVsbA=="
        }
      ]
    },
...
}
```


## AFT Workflow:
<img width="900" alt="image" src="https://github.com/aws-6w8hnx/ct-workshop-aft/assets/104741984/3612bddd-2b77-4ea0-84bc-c47f9885ad8f">


## AFT Github Repos:

- AFT Account requests: [aft-account-request](https://github.com/aws-ia/terraform-aws-control_tower_account_factory/tree/main/sources/aft-customizations-repos/aft-account-request)
- AFT Account provisioning customizations: [aft-customizations-repos](https://github.com/aws-ia/terraform-aws-control_tower_account_factory/tree/main/sources/aft-customizations-repos/aft-account-provisioning-customizations)
- AFT Global customizations: [aft-global-customizations](https://github.com/aws-ia/terraform-aws-control_tower_account_factory/tree/main/sources/aft-customizations-repos/aft-global-customizations)
- AFT Account customization: [aft-account-customizations](https://github.com/aws-ia/terraform-aws-control_tower_account_factory/tree/main/sources/aft-customizations-repos/aft-account-customizations}

