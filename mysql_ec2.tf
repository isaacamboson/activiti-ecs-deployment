
# mysql database being installed on an EC2 instance
resource "aws_instance" "act6" {
  ami                  = data.aws_ami.mysql_ami.id
  instance_type        = "t2.medium"
  key_name             = "private-key-kp"
  iam_instance_profile = "ec2_to_s3_admin"

  network_interface {
    network_interface_id  = aws_network_interface.act6.id
    device_index          = 0
    delete_on_termination = false
  }

  tags = {
    Name   = "act6"
    Backup = "Yes"
  }
}

# attaching network interface with a private IP in subnet to mysql ec2 db instance
resource "aws_network_interface" "act6" {
  subnet_id       = aws_subnet.private_subnets[1].id
  private_ips     = ["10.0.20.54"]
  security_groups = [aws_security_group.mysqldb-sg.id]
}
