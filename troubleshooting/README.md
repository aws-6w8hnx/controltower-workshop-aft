# Troubleshooting

Github: https://github.com/aws-ia/terraform-aws-control_tower_account_factory

Components: https://docs.aws.amazon.com/controltower/latest/userguide/aft-components.html

## Learning Outcomes
  - [Troubleshoot issues related to the account customizations workflow with AFT account customization request tracing](#troubleshoot-issues-related-to-the-account-customizations-workflow-with-aft-account-customization-request-tracing)
  - [Troubleshoot issues related to customizations invocation](#troubleshoot-issues-related-to-customizations-invocation)
  - [Troubleshoot issues related to account provisioning/registration](#troubleshoot-issues-related-to-account-provisioningregistration)

## [Troubleshoot issues related to account provisioning/registration](https://docs.aws.amazon.com/controltower/latest/userguide/account-troubleshooting-guide.html#w32aac32c31c45b9)

![Diagram](https://docs.aws.amazon.com/images/controltower/latest/userguide/images/high-level-aft-diagram.png)

### Account request already exists OR Account request did not trigger account creation.

* Check the CodeBuild logs for any errors or issues during the account request for the build `ct-aft-account-request`. This is located under the log group `/aws/codebuild/ct-aft-account-request` OR you can access the codebuild execution log via the CodePipeline pipeline `ct-aft-account-request`.

* Check any Service Catalog provisioning issues in "Provisioned Products" for the account in the Control Tower management account. The product name will be the "AccountName" you specified in the `account-request.tf` file. Troubleshoot as you normally do with Service Catalog issues.

* If you don't see any accounts provisioned on Service Catalog then it could be that the account request was not sent to SQS for processing OR failure when processing the request. To troubleshoot check the following logs:

  * `/aws/lambda/aft-account-request-action-trigger`
    * This logs events for the lambda function `aft-account-request-action-trigger` responsible for handling what to do with the request and sends account requests to the SQS queue for processing. This triggers when an account request entry is added in the `aft-request` table on DynamoDB.

  ![1](https://github.com/dansor-AZ/AFT-Troubleshooting/assets/108446227/73f9efb5-a030-408b-a39b-c631d13f9386)

  * `/aws/lambda/aft-account-request-processor`
    * This logs events for the lambda function `aft-account-request-processor` responsible for polling or reading the SQS queue for account requests and performs needed action e.g. creating product in Service Catalog.

  You can query both log groups above using CW Logs Insights:

  ```
  fields @timestamp, @message, @logStream, @log
  | sort @timestamp desc
  | filter @message like "error"
  ```

### Malformed account request

* Make sure the `account-request.tf` file follows the expected schema. You can refer to this [example](https://github.com/aws-ia/terraform-aws-control_tower_account_factory/blob/main/sources/aft-customizations-repos/aft-account-request/examples/account-request.tf).

* Malformed account request failures would show up in the log `/aws/codebuild/ct-aft-account-request` OR you can access the codebuild execution log via the CodePipeline pipeline `ct-aft-account-request`.

### Unable to register or import existing CT accounts into AFT.

* Before registering or importing existing accounts into AFT, make sure that the account meets the [prerequisites](https://docs.aws.amazon.com/controltower/latest/userguide/aft-update-account.html#aft-update-account-not-provision):

  * Enrolled in AWS Control Tower.
  * Part of the AWS Control Tower organization.

* Make sure that the account details specified in `control_tower_parameters` in the account request ".tf" file matches the account details specified in the service catalog product.

> account-request.tf

```
  control_tower_parameters = {
    AccountEmail = "dansor+AWSAFTTwo@amazon.com"
    AccountName  = "DansorAWSAFTTerraformTwo"
    # Syntax for top-level OU
    ManagedOrganizationalUnit = "Sandbox"
    # Syntax for nested OU
    # ManagedOrganizationalUnit = "Sandbox (ou-xfe5-a8hb8ml8)"
    SSOUserEmail     = "dansor+AWSAFTTwo@amazon.com"
    SSOUserFirstName = "AWS"
    SSOUserLastName  = "AFT"
  }
```

> Service Catalog

![1](https://github.com/dansor-AZ/AFT-Troubleshooting/assets/108446227/42a6aed1-a3df-40af-bb94-6d0ea07baf4e)

> OR Match account detail in IAM Identity Centre

![2](https://github.com/dansor-AZ/AFT-Troubleshooting/assets/108446227/053d7e1e-c780-471b-a7c7-9f687edb7055)

Otherwise, you will get the error below.

```
An error occurred (AccessDenied) when calling the AssumeRole operation: User: 
arn:aws:sts::123213213213:assumed-role/AWSAFTAdmin/AWSAFT-Session is not authorized to perform: sts:AssumeRole on 
resource: arn:aws:iam:::role/AWSAFTExecution
```

> The permission issue is thrown not because of access denied but because it couldn't find any resource to assume with the name `arn:aws:iam:::role/AWSAFTExecution`. This is normally of the format `arn:aws:iam::<ACCOUNT_ID>:role/AWSAFTExecution` which indicates the `ACCOUNT_ID` as well.

Log Groups:

* `/aws/codebuild/ct-aft-account-request`
* `/aws/codebuild/aft-create-pipeline`
* `/aws/lambda/aft-account-request-action-trigger`
* `/aws/lambda/aft-account-request-audit-trigger`
* `/aws/lambda/aft-account-request-processor`

## Troubleshoot issues related to customizations invocation

### Target account not onboarded to Account Factory

Make sure all accounts that are included in a customization request have been onboarded to Account Factory. For more information, see Update an existing account.

### Failed to create account before account customizations pipeline is created; can't customize account

Ensure that the account creation or request succeeds as if this step fails no account customizations will be invoked.

### Target account not onboarded to Account Factory

Make sure all accounts that are included in a customization request have been onboarded to Account Factory. For more information, see Update an existing account.

## [Troubleshoot issues related to the account customizations workflow with AFT account customization request tracing](https://docs.aws.amazon.com/controltower/latest/userguide/aft-account-customization-options.html#aft-customization-request)


Account customization workflows that are based on AWS Lambda emit logs containing target account and customization request IDs. AFT allows you to trace and troubleshoot customization requests with Amazon CloudWatch Logs by providing you with CloudWatch Logs Insights queries that you can use to filter CloudWatch Logs related to your customization request by your target account or customization request ID.


This queries the related log groups used to record events during the customization workflow:

* `/aws/codebuild/aft-account-provisioning-*`
  * /aws/lambda/aft-account-provisioning-framework-create-aft-execution-role
  * /aws/lambda/aft-account-provisioning-framework-persist-metadata
  * /aws/lambda/aft-account-provisioning-framework-tag-account
  * /aws/lambda/aft-account-provisioning-framework-account-metadata-ssm
&nbsp;
* `/aws/lambda/aft-*`
  * /aws/lambda/aft-delete-default-vpc
  * /aws/lambda/aft-enroll-support
  * /aws/lambda/aft-enable-cloudtrail

### How to query issues or errors during the account customization workflow:

1. Open the CloudWatch console at https://console.aws.amazon.com/cloudwatch/.

2. From the navigation pane, choose Logs, and then choose Logs insights.

3. Choose Queries.

4. Under Sample queries, choose Account Factory for Terraform, and then select one of the following queries:


&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![Customization](https://i.imgur.com/OTKB1IF.png)


   * Customization Logs by Account ID

      > fields @timestamp, log_message.account_id as target_account_id, log_message.customization_request_id as customization_request_id, log_message.detail as detail, @logStream
      | sort @timestamp desc
      | filter log_message.account_id == "YOUR-ACCOUNT-ID" and @message like /customization_request_id/

      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;![4](https://github.com/dansor-AZ/AFT-Troubleshooting/assets/108446227/6fd65856-ab03-4d8d-a3ff-5d4c888c57d5)

   * Customization Logs by Customization Request ID

      >fields @timestamp, log_message.account_id as target_account_id, log_message.customization_request_id as customization_request_id, log_message.detail as detail, @logStream
      | sort @timestamp desc
      | filter log_message.customization_request_id == "YOUR-CUSTOMIZATION-REQUEST-ID"
&nbsp;

## Other Errors you may encounter:

### Error in Account Customization Pipeline: `Error refreshing state: state data in S3 does not have the expected content.`

This error normally occurs as the current terraform state stored in S3 (`/`) is not in sync with the terraform lock state stored by DynamoDB. To remediate, remove the out-of-sync entry in AWS DynamoDB Table. There will be a LockID entry in the table containing state and expected checksum which you should delete and that will be re-generated after re-running terraform init.

* Terraform State File in S3: `aft-backend-<ACCOUNT_NUMBER>-primary-region/account-provisioning-customizations/terraform.tfstate`

* Terraform State/Lock file in DynamoDB Table (aft-backend-<ACCOUNT_NUMBER>): `aft-backend-<ACCOUNT_NUMBER>-primary-region/account-provisioning-customizations/terraform.tfstate-md5`

> For instance AFT management account is 12345678900.

1. Login to your AFT Management account "12345678900"
2. Go to DynamoDB service in your AWS console
3. In the Navigation panel on the left side under "Tables" select "Explore items"
4. In the "Tables" section select "aft-backend-12345678900"
5. In the "Items returned" panel select "aft-backend-12345678900-primary-region/account-provisioning-customizations/terraform.tfstate-md5"
6. Actions -> Delete items

Once that has been deleted try to rerun your AFT pipeline again and verify if the issue still persists.

### Step function `aft-account-provisioning-framework` execution fail: `States.TaskFailed in step: aft_account_provisioning_framework_aft_features` when importing more than 10 accounts into AFT.

This is not a limit on Step functions but the quota limits imposed by Account factory such that only up to five (5) account-related operations in progress simultaneously and up to ten (10) control-related operations at a time can be in progress. See [doc](https://docs.aws.amazon.com/controltower/latest/userguide/limits.html#controltower-limits). For instance, if you are importing 15 accounts into AFT, 10 of which will succeed while the rest will be discarded. You will see this error via the Step Function `aft-account-provisioning-framework` executions.
