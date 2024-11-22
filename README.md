# AWS Control Tower Account Factory for Terraform (AFT)
A Control Tower Workshop for Account Factory for Terraform (AFT)

## :question: A question asked from the first session :question:
### When you configure your landing zone for new Regions, AWS Control Tower detective controls adhere to the following rules:

- [You can’t apply new detective controls to existing OUs containing accounts that are not updated. When you’ve configured your AWS Control Tower landing zone into a new Region (by updating your landing zone), you must update existing accounts in your existing OUs before you can enable new detective controls on those OUs and accounts.](https://docs.aws.amazon.com/controltower/latest/userguide/region-how.html#:~:text=You%20can%E2%80%99t%20apply,OUs%20and%20accounts.)

#### Replication:
<img width="600" alt="image" src="https://github.com/aws-6w8hnx/controltower-workshop-aft/assets/29943707/f8b58315-5ea2-46fc-8420-e65cb2d05a84">

When enabling `detective` Controls (in All controls -> Search for `Behavior = Detective` -> select a control and enable it for the `cfn` OU), you will see the Error Message below:  
<img width="600" alt="image" src="https://github.com/aws-6w8hnx/ct-workshop-aft/assets/104741984/061df152-5167-4049-bbef-326ac88c86f0">

---
## :beginner: Introduce to Terraform

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

5. Deploy and destroy:
```bash
# Prepare your working directory for other commands
terraform init

# Show changes required by the current configuration
terraform plan -out tfplan

# Create or update infrastructure
terraform apply "tfplan"

# Destroy previously-created infrastructure
terraform destroy
```


#### Two examples:
* A bad example: https://github.com/aws-6w8hnx/controltower-workshop-aft/tree/main/terraform/a-bad-example
* best practice: https://github.com/aws-6w8hnx/controltower-workshop-aft/tree/main/terraform/best-practice


### 2. Terraform Modules

* Simple module: https://github.com/aws-6w8hnx/controltower-workshop-aft/tree/main/terraform/use-a-module

### 3. Terraform state
Terraform must store state about your managed infrastructure and configuration. This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures.

#### :one: **Best practice** (Sample saved in samples dir):
* Store the terraform state file in an s3 bucket,
* Or use a remote backend to store the file in Terraform Cloud/Enterprise


### :two: To move local state file to a remote backend:

- Copy the sample backend_s3.tf content to backend.tf,
- run the following:

```
# Reconfigure a backend, and attempt to migrate any existing state
terraform init -migrate-state
```


* Here is a sample of a part of `tfstate` file:
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


## :eight_spoked_asterisk: Deep dive to AFT workflow:

### :one: [Account Factory Request](https://controltower.aws-management.tools/automation/aft_repo/#account-factory-request)
<img width="900" alt="image" src="https://github.com/aws-6w8hnx/controltower-workshop-aft/blob/fae3ab10e96c38dddf9f6f6da207616e19e2cc28/static_images/high-level-aft-diagram.png">

Please be noted the above diagram was miss leading on the `CT Update` No workflow, because:
1. When there is no update, the state machine: `aft-account-provisioning-framework` was triggered by lambda: `aft-account-request-action-trigger` directly, see below [log](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/aft-account-request-action-trigger?tab=monitoring):
```json
2024-11-21T05:24:21.714Z
{
    "time_stamp": "2024-11-21 05:24:21,714",
    "module": "aft_utils",
    "log_level": "INFO",
    "log_message": "Starting SFN execution of arn:aws:states:us-east-1:239342779695:stateMachine:aft-account-provisioning-framework"
}
```
2. The lambda: `aft-invoke-aft-account-provisioning-framework` is only triggered when a new account created.



#### Event Bridge
In Control Tower Management Account: `453917013318`, event bridge rule: `aft-capture-ct-events` with cross account target, the target and rule details show below:

- **Target** (cross account: AFT Management Account Id: `239342779695`)
```ruby
Target Name: arn:aws:events:us-east-1:239342779695:event-bus/aft-events-from-ct-management
Type:        Event bus in a different account or Region
Arn:         arn:aws:events:us-east-1:239342779695:event-bus/aft-events-from-ct-management
```

- **Rule**:
```json
{
  "detail": {
    "eventName": ["CreateManagedAccount", "UpdateManagedAccount"]
  },
  "detail-type": ["AWS Service Event via CloudTrail"],
  "source": ["aws.controltower"]
}
```

#### State machines
- Name:      `aft-account-provisioning-framework`
- Execution: `0ff6d6db-c088-459e-a999-2f7df4403a23`
<img width="900" alt="image" src="https://github.com/aws-6w8hnx/controltower-workshop-aft/blob/6e2f583f5145a8ab7431bc8ae3c851127cd8e8cf/static_images/aft-state-machine-execution%20.png">

### :two: [Provisioning Framework](https://controltower.aws-management.tools/automation/aft_repo/#provisioning-framework)
<img width="900" alt="image" src="https://github.com/aws-6w8hnx/controltower-workshop-aft/assets/29943707/0c62985d-1d54-4190-8002-3a189e8d14dc">


## AFT Github Repos:

- AFT Account requests: [aft-account-request](https://github.com/aws-ia/terraform-aws-control_tower_account_factory/tree/main/sources/aft-customizations-repos/aft-account-request)
- AFT Account provisioning customizations: [aft-customizations-repos](https://github.com/aws-ia/terraform-aws-control_tower_account_factory/tree/main/sources/aft-customizations-repos/aft-account-provisioning-customizations)
- AFT Global customizations: [aft-global-customizations](https://github.com/aws-ia/terraform-aws-control_tower_account_factory/tree/main/sources/aft-customizations-repos/aft-global-customizations)
- AFT Account customization: [aft-account-customizations](https://github.com/aws-ia/terraform-aws-control_tower_account_factory/tree/main/sources/aft-customizations-repos/aft-account-customizations)

