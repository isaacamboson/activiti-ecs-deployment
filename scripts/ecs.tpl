#!/bin/bash

# #Configure cluster name using the template variable ${ecs_cluster_name}
# echo ECS_CLUSTER=${ecs_cluster_name} >> /etc/ecs/ecs.config

#------------------------------------------------------------------------

cat << 'EOF' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
    "metrics": {
        "metrics_collected": {
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 30
            }
        }
    }
}
EOF

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

cd /home/ec2-user

sudo yum update -y

#install mysql database
sudo yum install mysql -y

sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd mariadb-server
sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo systemctl status mariadb

touch /home/ec2-user/config_out.txt
yum install -y aws-cli

#associating the EC2 instances with the cluster
# echo '#!/usr/bin/env bash' > /home/ec2-user/ecs_config.sh
echo '#!/bin/bash' > /home/ec2-user/ecs_config.sh
echo 'sleep 120' >> /home/ec2-user/ecs_config.sh
echo 'echo ECS_CLUSTER=activiti-app-cluster >> /etc/ecs/ecs.config' >> /home/ec2-user/ecs_config.sh

chmod 744 /home/ec2-user/ecs_config.sh

sh /home/ec2-user/ecs_config.sh 1>/home/ec2-user/config_out.txt 2>/home/ec2-user/config_out.txt & disown

#Installing Docker
sudo amazon-linux-extras install docker -y

#Starting Docker 
sudo systemctl start docker
sudo systemctl enable docker

sudo yum update -y ecs-init


