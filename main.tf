data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_subnet" "firstsub" { id = var.subnets_lambda[0] }

/*
To avoid this situation, we recommend that you don’t create secret names ending with a hyphen followed by six characters.
https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_DeleteResourcePolicy.html
*/
locals {
  secret_name = "${random_string.namefix.result}-${var.name}"
}

resource "aws_iam_role" "lambda_rotation" {
  name               = "${var.name}-rotation_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambdabasic" {
  name       = "${var.name}-lambdabasic"
  roles      = [aws_iam_role.lambda_rotation.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "SecretsManagerRDSMySQLRotationSingleUserRolePolicy" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DetachNetworkInterface",
    ]
    resources = [
    "*", ]
  }
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${local.secret_name}*",
    ]
  }
  statement {
    actions = [
    "secretsmanager:GetRandomPassword"]
    resources = [
    "*", ]
  }
}

resource "aws_iam_policy" "SecretsManagerRDSMySQLRotationSingleUserRolePolicy" {
  name   = "${var.name}-SecretsManagerRDSMySQLRotationSingleUserRolePolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.SecretsManagerRDSMySQLRotationSingleUserRolePolicy.json
}


resource "aws_iam_policy_attachment" "SecretsManagerRDSMySQLRotationSingleUserRolePolicy" {
  name = "${var.name}-SecretsManagerRDSMySQLRotationSingleUserRolePolicy"
  roles = [
  aws_iam_role.lambda_rotation.name]
  policy_arn = aws_iam_policy.SecretsManagerRDSMySQLRotationSingleUserRolePolicy.arn
}

resource "aws_security_group" "lambda" {
  vpc_id = data.aws_subnet.firstsub.vpc_id
  name   = "${var.name}-Lambda-SecretManager"
  tags = {
    Name = "${var.name}-Lambda-SecretManager"
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
}

variable "filename" { default = "rotate-code-mysql" }
resource "aws_lambda_function" "rotate-code-mysql" {
  filename         = "${path.module}/${var.filename}.zip"
  function_name    = "${var.name}-${var.filename}"
  role             = aws_iam_role.lambda_rotation.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/${var.filename}.zip")
  runtime          = "python3.7"
  vpc_config {
    subnet_ids         = var.subnets_lambda
    security_group_ids = [aws_security_group.lambda.id, var.rds_security_group_id]
  }
  timeout     = 300
  memory_size = 128
  description = "Conducts an AWS SecretsManager secret rotation for RDS MySQL using single user rotation scheme"
  environment {
    variables = {
      #https://docs.aws.amazon.com/general/latest/gr/rande.html#asm_region
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${data.aws_region.current.name}.amazonaws.com"
    }
  }
}

resource "aws_lambda_permission" "allow_secret_manager_call_Lambda" {
  function_name = aws_lambda_function.rotate-code-mysql.function_name
  statement_id  = "AllowExecutionSecretManager"
  action        = "lambda:InvokeFunction"
  principal     = "secretsmanager.amazonaws.com"
}
/* not yet available
data "aws_iam_policy_document" "kms" {
  statement {
    sid = "Enable IAM User Permissions"
    actions = [ "*" ]
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["kms:*"]
  }

  statement {
    sid = "Allow use of the key",
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    principals {
      type = "AWS"
      identifiers = ["${aws_iam_role.lambda_rotation.arn}"]
      #identifiers = ["${concat(list("arn:aws:iam::563249796440:role/testsecret-automatic-password-manager-rotation_lambda"),var.additional_kms_role_arn)}"]
    }
    resources = ["*"]
  }

  statement {
    sid = "Allow attachment of persistent resources",
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    principals {
      type = "AWS"
      identifiers = ["${aws_iam_role.lambda_rotation.arn}"]
    }
    resources = ["*"]
    condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values = [ "true"]
    }
  }
}
*/

resource "aws_kms_key" "secret" {
  description         = "Key for secret ${var.name}"
  enable_key_rotation = true
  #policy              = "${data.aws_iam_policy_document.kms.json}"
  policy = <<POLICY
{
  "Id": "key-consolepolicy-3",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        ]
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow use of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.lambda_rotation.arn}"
        ]
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.lambda_rotation.arn}"
        ]
      },
      "Action": [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_kms_alias" "secret" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.secret.key_id
}

# Bugfix: this hash is used to make
# secrets manager operations idempotent across multiple runs
# instead of failing when the secret already exists, but was deleted
resource "random_string" "namefix" {
  length = 3
  upper = true
  special = false
}

resource "aws_secretsmanager_secret" "secret" {
  description = var.secret_description
  kms_key_id  = aws_kms_key.secret.key_id
  name        = local.secret_name
}

resource "aws_secretsmanager_secret_rotation" "secret" {
  secret_id           = aws_secretsmanager_secret.secret.id
  rotation_lambda_arn = aws_lambda_function.rotate-code-mysql.arn

  rotation_rules {
    automatically_after_days = var.rotation_days
  }
}

resource "aws_secretsmanager_secret_version" "secret" {
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = <<EOF
{
  "username": "${var.mysql_username}",
  "engine": "mysql",
  "dbname": "${var.mysql_dbname}",
  "host": "${var.mysql_host}",
  "password": "${var.mysql_password}",
  "port": ${var.mysql_port},
  "dbInstanceIdentifier": "${var.mysql_dbInstanceIdentifier}"
}
EOF
}
