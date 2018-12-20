variable "name" {
  description = "This name will be used as prefix for all the created resources"
}
variable "secret_description" {
  description = "This field is the description for the secret manager object"
  default     = "secret manager for mysql/aurora"
}
variable "rotation_days" {
  default     = 30
  description = "How often in days the secret will be rotated"
}
variable "subnets_lambda" {
  type = "list"
  description = "The subnets where the Lambda Function will be run"
}
variable "mysql_username" {
  description = "The MySQL/Aurora username you chose during RDS creation or another one that you want to rotate"
}
variable "mysql_dbname" {
  description = "The Database name inside your RDS"
}
variable "mysql_host" {
  description = "The RDS endpoint to connect to your database"
}
variable "mysql_password" {
  description = "The password that you want to rotate, this will be changed after the creation"
}
variable "mysql_port" {
  default = 3306
  description = "In case you don't have your MySQL on default port and you need to change it"
}
variable "mysql_dbInstanceIdentifier" {
  description = "The RDS Identifier in the webconsole"
}
/* Not yet available 
variable "additional_kms_role_arn" {
  type = "list"
  default = [""]
  description = "If you want add another role of another resource to access to the kms key used to encrypt the secret"
}
*/
