This module will create all the resources to store and rotate a MySQL or Aurora password using the AWS Secrets Manager service.

# Schema

![schema](https://raw.githubusercontent.com/giuseppeborgese/terraform-aws-secret-manager-with-rotation/master/schema.jpg)

# Prerequisites
* A VPC with private subnets and accessibilty to AWS Secrets Manager Endpoint, see below for more details.
* An RDS with MySQL or Aurora already created and reacheable from the private subnets


# Usage Example
``` hcl
module "secret-manager-with-rotation" {
  source                     = "giuseppeborgese/secret-manager-with-rotation/aws"
  version                    = "<always choose the latest version displayed in the upper right corner of this page>"
  name                       = "PassRotation"
  rotation_days              = 10
  subnets_lambda             = ["subnet-xxxxxx", "subnet-xxxxxx"]
  mysql_username             = "giuseppe"
  mysql_dbname               = "my_db_name"
  mysql_host                 =  "mysqlEndpointurl.xxxxxx.us-east-1.rds.amazonaws.com"
  mysql_password             = "dummy_password_will_we_rotated"
  mysql_dbInstanceIdentifier = "my_rds_db_identifier"
}
```

### Video Tutorial
Take a look to the video to see the module in action


[![Rotate automatically a MySQL or Aurora password using AWS Secrets Manager and Terraform](https://img.youtube.com/vi/ljZ6BZJabUk/0.jpg)](https://youtu.be/ljZ6BZJabUk)


The subnets specified needs to be private and with internet access to reach the [AWS secrets manager endpoint](https://docs.aws.amazon.com/general/latest/gr/rande.html#asm_region)
You can use a NAT GW or configure your Routes with a VPC Endpoint like is described in [this guide](https://aws.amazon.com/blogs/security/how-to-connect-to-aws-secrets-manager-service-within-a-virtual-private-cloud/)

# Further details
* Interesting to [force the rotation](https://forums.aws.amazon.com/thread.jspa?threadID=280093&tstart=0)

# If you like it
Please if you like this module, thumbs up on the youtube video and leave a comment as well for any questions.
