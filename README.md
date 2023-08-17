# ct-workshop-aft
A Control Tower Workshop for Account Factory for Terraform (AFT)

- [You can’t apply new detective controls to existing OUs containing accounts that are not updated. When you’ve configured your AWS Control Tower landing zone into a new Region (by updating your landing zone), you must update existing accounts in your existing OUs before you can enable new detective controls on those OUs and accounts.](https://docs.aws.amazon.com/controltower/latest/userguide/region-how.html#:~:text=You%20can%E2%80%99t%20apply,OUs%20and%20accounts.)

### Replication:
<img width="600" alt="image" src="https://github.com/aws-6w8hnx/ct-workshop-aft/assets/104741984/32e19305-2a05-416a-8807-101001e34234">

When enable `detective` Controls (in All controls -> Search for `Behavior = Detective` -> select a control and enable it for the `cfn` OU), you will see the Error Message below:
<img width="600" alt="image" src="https://github.com/aws-6w8hnx/ct-workshop-aft/assets/104741984/061df152-5167-4049-bbef-326ac88c86f0">

