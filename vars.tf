#AWS Required
variable "AWS_REGION" {    
    default = "us-east-1"
}
variable "APP_SHORT" {
  default = "assessment"
}
variable "ENV_CODE" {
  default = "p"
}

variable "VPC_CIDR" {
  default = "10.132.27.0/24"
}
variable "PUB_AZA_CIDR" {
  default = "10.132.27.0/27"
}
variable "PUB_AZB_CIDR" {
  default = "10.132.27.32/27"
}
variable "PRIV_AZA_CIDR" {
  default = "10.132.27.192/27"
}
variable "PRIV_AZB_CIDR" {
  default = "10.132.27.224/27"
}

variable "acl_value" {
    default = "private"
}

variable "bucket_name" {
    default = "sourcefuses3"
}

variable "ECS_INSTANCE_ROLE" {
  default = "ecsInstanceRole"
}


#Tags
variable "ENVIRONMENT" {
  default = "Production"
}
variable "PROJECT_ID" {
  default = "Sourcefuse_Assessment"
}

