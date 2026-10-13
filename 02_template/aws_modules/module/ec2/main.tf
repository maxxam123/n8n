resource "aws_instance" "main" {
  instance_type = var.instance_type
  subnet_id = var.subnet
  ami = var.ami
}
