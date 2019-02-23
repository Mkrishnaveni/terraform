variable "region" {
default = "ap-south-1"
}
variable "vpc" {
default = "10.1.0.0/16"
description = "the vpc cdir"
}
variable "public" {
default = "10.1.1.0/24"
description = "the public subnet cdir"
}
variable "private" {
default = "10.1.2.0/24"
description = "the private subnet cdir"
}
variable "pub_zone" {
default = "ap-south-1a"
description = "the pub_zone cdir"
}
variable "pri_zone" {
default = "ap-south-1b"
description = "the pri_zone cdir"
}
variable "ami" {
default = "ami-0ad42f4f66f6c1cc9"
description = "the ami"
}
variable "instance_type" {
default = "t2.micro"
description = "the instance type"
}
variable "key_name" {
default = "linux"
description = "the key pair"
}

