resource "aws_instance" "terraform-ec2" {
  ami           = var.ami_value
  instance_type = lookup(var.instance_type_value, terraform.workspace, "t2.micro")

  tags = {
    Name = "Terraform-EC2"
  }
}