variable "AWS_ACCESS_KEY_ID" {
  type      = string
  sensitive = true
}
variable "AWS_SECRET_ACCESS_KEY" {
  type      = string
  sensitive = true
}
variable "aws_region" {
  default = "us-east-1"
}
variable "region_azs" {
  type = map(any)
  default = {
    az1 = "us-east-1a"
    az2 = "us-east-1b"
    az3 = "us-east-1c"
  }
}

variable "key_name" {
  default   = "your-key-name-here"
  sensitive = true
}
variable "user" {
  default   = "ec2-user"
  sensitive = true
}
variable "public_key_path" {
  default   = "your-public-key.pub"
  sensitive = true
}
variable "priv_key_path" {
  default   = "your-private-key.pem"
  sensitive = true
}
variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}
variable "consul_subnet_cidr1" {
  description = "CIDR for the Consul Subnet 1"
  default     = "10.0.1.0/24"
}
variable "consul_subnet_cidr2" {
  description = "CIDR for the Consul Subnet 2"
  default     = "10.0.2.0/24"
}
variable "consul_subnet_cidr3" {
  description = "CIDR for the Consul Subnet 3"
  default     = "10.0.3.0/24"
}
variable "owner" {
  description = "Infra Owner"
  default     = "Hala Elhamahmy"
}
variable "environment" {
  description = "Infra Env"
  default     = "Consul"
}
variable "connection_timeout" {
  default = "120s"
}


