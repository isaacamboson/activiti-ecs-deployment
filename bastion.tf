# Bastion AWS instance
resource "aws_instance" "bastion-host" {
  count                       = var.stack_controls["ec2_create"] == "Y" ? 2 : 0
  ami                         = data.aws_ami.stack_ami.id
  instance_type               = var.EC2_Components["instance_type"]
  vpc_security_group_ids      = [aws_security_group.bastion-sg.id]
  key_name                    = "bastion_kp"
  subnet_id                   = element(aws_subnet.pub_subnets.*.id, count.index)
  associate_public_ip_address = "true"
  iam_instance_profile        = "ec2_to_s3_admin"
  user_data                   = data.template_file.bastion_s3_cp_bootstrap.rendered

  tags = {
    Name        = "Bastion_${local.ApplicationPrefix}"
    Environment = var.environment
    OwnerEmail  = var.OwnerEmail
  }
}
