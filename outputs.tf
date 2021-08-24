output "kms_key_arn" {
  description = "KMS Key ARN"
  value       = join("", aws_kms_key.default.*.arn)
}

output "kms_alias_name" {
  description = "KMS Key Alias name"
  value       = join("", aws_kms_alias.default.*.name)
}

output "iam_role_arn" {
  description = "Lambda IAM Role ARN"
  value       = join("", aws_iam_role.default.*.arn)
}

output "iam_role_id" {
  description = "Lambda IAM Role ID"
  value       = join("", aws_iam_role.default.*.id)
}

output "iam_role_name" {
  description = "Lambda IAM Role name"
  value       = join("", aws_iam_role.default.*.name)
}

output "lambda_function_arn" {
  description = "Lambda Function ARN"
  value       = join("", aws_lambda_function.default.*.arn)
}

output "lambda_function_name" {
  description = "Lambda Function name"
  value       = join("", aws_lambda_function.default.*.function_name)
}

output "secretsmanager_secret_arn" {
  description = "Secrets Manager Secret ARN"
  value       = join("", aws_secretsmanager_secret.default.*.arn)
}

output "secretsmanager_secret_name" {
  description = "Secrets Manager Secret Name"
  value       = module.slash.id
}

output "secretsmanager_secret_version_id" {
  description = "Secrets Manager Secret version ID"
  value       = join("", aws_secretsmanager_secret_version.default.*.version_id)
}

#output "security_group_id" {
#  description = "ID of the Security Group"
#  value       = aws_security_group.default.id
#}

