resource "aws_key_pair" "wireguard" {
  key_name   = "wireguard"
  public_key = var.wireguard_public_key
}

resource "aws_security_group" "wireguard" {
  name        = "wireguard"
  description = "Allow wireguard UDP access"

  ingress {
    description      = "wireguard"
    from_port        = 51820
    to_port          = 51820
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    description = "Allow ping"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "wireguard"
  }
}

resource "aws_launch_template" "wireguard" {
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
}

resource "aws_instance" "wireguard" {
  ami           = var.ami_value
  instance_type = var.instance_type_value
  key_name      = aws_key_pair.wireguard.key_name

  launch_template {
    id      = aws_launch_template.wireguard.id
    version = aws_launch_template.wireguard.latest_version
  }

  vpc_security_group_ids = [aws_security_group.wireguard.id]

  tags = {
    Name = "wireguard"
  }

  provisioner "file" {
    source      = "aws_server_setup.sh"
    destination = "/home/ubuntu/aws_server_setup.sh"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_dns
    private_key = file(var.wireguard_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/aws_server_setup.sh",
      "sudo /home/ubuntu/aws_server_setup.sh",
      "sudo /usr/sbin/shutdown -r 1"
    ]
  }
}

resource "null_resource" "wait_for_reboot" {
  depends_on = [aws_instance.wireguard]

  provisioner "local-exec" {
    command = "sleep 2 && until ping -c1 ${aws_instance.wireguard.public_dns}; do sleep 2; done"
  }
}
