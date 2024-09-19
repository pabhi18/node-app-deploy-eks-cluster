#VPC
variable "region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.11.0/24"
}

variable "availability_zone" {
  description = "Availability Zone"
  type        = string
  default     = "us-east-1a"
}

variable "rt_cidr" {
    description = "CIDR Block for the VPC"
    type = string
    default = "0.0.0.0/0"
}

#EC2

variable "key_name" {
  description = "Key Pair Name"
  type = string
  default = "test-k8"
}

variable "worker_count" {
  description = "Worker Nodes Count"
  type = number
  default = 2
}

variable "ami_id" {
  description = "AMI ID for Master Node"
  type = string
  default = "ami-0e86e20dae9224db8"
}
