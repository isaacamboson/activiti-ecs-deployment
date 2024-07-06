data "template_file" "activiti-app" {
  template = file(format("%s/scripts/image.json", path.module))

  vars = {
    app_image1  = var.app_image
    app_port1   = var.app_port
    ec2_cpu1    = var.ec2_cpu
    ec2_memory1 = var.ec2_memory
    aws_region1 = var.AWS_REGION
    app_name1   = local.ApplicationPrefix
  }
}

data "template_file" "ecs_user_data" {
  template = file(format("%s/scripts/ecs.tpl", path.module))

  vars = {
    ecs_cluster_name = aws_ecs_cluster.activiti-cluster.name
  }
}

data "template_file" "bastion_s3_cp_bootstrap" {
  template = file(format("%s/scripts/bastion_s3_key_copy.tpl", path.module))
  vars = {
    s3_bucket = local.db_creds.s3_bucket
    pem_key   = "private-key-kp.pem"

  }
}