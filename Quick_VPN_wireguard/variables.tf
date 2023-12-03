variable "region" {
    type = string
    default = "ap-south-1"
}

# EC2

variable "ami_value" {
  type = string
  default = "ami-0287a05f0ef0e9d9a"
}

variable "instance_type_value" {
  type = string
  default = "t2.micro"
}

# SSH key pair

variable "wireguard_public_key" {
  type = string
}

variable "wireguard_private_key" {
  type = string
}