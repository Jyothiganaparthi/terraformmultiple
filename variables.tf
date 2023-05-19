variable "region"{}
#variable "access_key"{}
#variable "secret_key"{}
variable "vpc-cidr" {}
variable "vpc-name"{}
variable "azs"{
    type = list
    default =["us-east-2a","us-east-2b","us-east-2c"]
}
variable "public_cidrs" {
    type = list
    default = ["10.0.0.0/24","10.0.1.0/24","10.0.2.0/24"]
}
variable "private_cidrs"{
    type = list
    default = ["10.0.10.0/24","10.0.20.0/24","10.0.30.0/24"]
}
variable "igw" {}
variable "route1"{}
variable "route2" {}
variable "sec"{}
