terraform {
  backend "s3" {
    bucket         = "example-state-bucket"
    encrypt        = true
    key            = "example/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
  }
}


provider "aws" {
  region = "eu-central-1"
}


module "db_instance_example" {
  source = "git::https://github.com/dfds/aws-modules-rds.git"

#     Provide a cost centre for the resource.
#     Valid Values: .
#     Notes: This set the dfds.cost_centre tag. See recommendations [here](https://wiki.dfds.cloud/en/playbooks/standards/tagging_policy).
cost_centre = "example"

#     Specify data classification.
#     Valid Values: public, private, confidential, restricted
#     Notes: This set the dfds.data.classification tag. See recommendations [here](https://wiki.dfds.cloud/en/playbooks/standards/tagging_policy).
data_classification = "example"

#     Specify the staging environment.
#     Valid Values: "dev", "test", "staging", "uat", "training", "prod".
#     Notes: The value will set configuration defaults according to DFDS policies.
environment = "example"

#     Specify the name of the RDS instance to create.
#     Valid Values: .
#     Notes: .
identifier = "example"

#     Specify whether or not to enable access from Kubernetes pods.
#     Valid Values: .
#     Notes: Enabling this will create the following resources:
#       - IAM role for service account (IRSA)
#       - IAM policy for service account (IRSA)
is_kubernetes_app_enabled = false

#     Specify whether or not to include proxy.
#     Valid Values: .
#     Notes: Proxy helps managing database connections. See [documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy-planning.html) for more information.
is_proxy_included = false

#     Specify additional security group rules for the RDS instance.
#     Valid Values: .
#     Notes: .
rds_security_group_rules = "example"

#     Specify service availability.
#     Valid Values: low, medium, high
#     Notes: This set the dfds.service.availability tag. See recommendations [here](https://wiki.dfds.cloud/en/playbooks/standards/tagging_policy).
service_availability = "example"

#     Provide a list of VPC subnet IDs.
#     Valid Values: .
#     Notes: IDs of the subnets must be in the same VPC as the RDS instance.
subnet_ids = "example"

#     Specify Username for the master DB user.
#     Valid Values: .
#     Notes: .
username = "example"

#     Specify the VPC ID.
#     Valid Values: .
#     Notes: .
vpc_id = "example"
}

output "iam_instance_profile_for_ec2" {
  description = "The name of the EC2 instance profile that is using the IAM Role that give AWS services access to the RDS instance and Secrets Manager"
  value       = try(module.db_instance_example.iam_instance_profile_for_ec2, null)
}
output "iam_role_arn_for_aws_services" {
  description = "The ARN of the IAM Role that give AWS services access to the RDS instance and Secrets Manager"
  value       = try(module.db_instance_example.iam_role_arn_for_aws_services, null)
}
output "instance_engine_info" {
  description = "The engine info for the selected engine of the RDS instance"
  value       = try(module.db_instance_example.instance_engine_info, null)
}
output "kubernetes_serviceaccount" {
  description = "If you create this Kubernetes ServiceAccount, you will get access to the RDS through IRSA"
  value       = try(module.db_instance_example.kubernetes_serviceaccount, null)
}