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
  type = map(string)
  default ={
    dev = "t2.micro"
    stage = "t2.small"
    prod = "t2.medium"
  }
}