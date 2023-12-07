# provider variables

variable "TENACY_OCID" {
  type = string
}

variable "USER_OCID" {
  type = string
}

variable "PRIVATE_KEY_PATH" {
  type = string
}

variable "FINGERPRINT" {
  type = string
}

variable "REGION" {
  type = string
}

# instance variables

variable "AD" {
  type = string
}

variable "COMPARTMENT_ID" {
  type = string
}

variable "SHAPE" {
  type = string
  default = "VM.Standard.A1.Flex"
}

variable "OCPUS" {
  type = string
  default = "4"
}

variable "MEMORY" {
  type = string
  default = "24"
}

variable "PUBLIC_KEY_PATH" {
  type = string
}

variable "SUBNET_ID" {
  type = string
}

variable "IMAGE_ID" {
  type = string
}
