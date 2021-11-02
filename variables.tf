variable "rotation_type" {
  type        = string
  description = "Is this `single` or `multi` user rotation?"
  default     = "single"

  validation {
    condition     = var.rotation_type == "single" || var.rotation_type == "multi"
    error_message = "The rotation_type value must be either `single` or `multi`."
  }
}

variable "rotation_days" {
  type        = number
  description = "How often in days the secret will be rotated"
  default     = 30
}

variable "subnets_lambda" {
  type        = list(any)
  description = "The subnets where the Lambda Function will be run"
}

variable "replica_regions" {
  type = list(object({
    kms_key_id = string
    region     = string
  }))
  description = "A list of objects containing the regions to which to replicate the secret. Each element in the list must be an object with `kms_key_id` and `region` keys. `kms_key_id` may be set to `null` to use the default AWS-managed KMS key."
  default     = []
}

variable "mysql_username" {
  type        = string
  description = "The MySQL/Aurora username you chose during RDS creation or another one that you want to rotate"
}

variable "mysql_dbname" {
  type        = string
  description = "The Database name inside your RDS"
}

variable "mysql_host" {
  type        = string
  description = "The RDS endpoint to connect to your database"
}

variable "mysql_password" {
  type        = string
  description = "The password that you want to rotate, this will be changed after the creation"
}

variable "mysql_port" {
  type        = number
  description = "In case you don't have your MySQL on default port and you need to change it"
  default     = 3306
}

variable "secretsmanager_masterarn" {
  type        = string
  description = "The ARN of the Secrets Manager which rotates the MySQL superuser"
  default     = ""
}

#variable "additional_kms_role_arn" {
#  type        = list
#  description = "If you want add another role of another resource to access to the kms key used to encrypt the secret"
#  default     = []
#}

variable "security_group" {
  type        = list(any)
  description = "The security group(s) where the Lambda Function will be run. This must have access to the RDS instance. The best option is to make this the RDS' security group and allow the SG to access itself"
}

variable "mysql_replicahost" {
  type        = string
  description = "The RDS replica endpoint to connect to your read-only database"
  default     = null
}

variable "secret_label_order" {
  type        = list(any)
  default     = ["namespace", "environment", "stage", "name", "attributes"]
  description = <<-EOT
    The naming order of the id output and Name tag.
    Defaults to ["namespace", "environment", "stage", "name", "attributes"].
    You can omit any of the 5 elements, but at least one must be present.
  EOT
}

