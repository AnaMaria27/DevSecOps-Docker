#!/bin/bash

sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker.service && systemctl enable docker.service
usermod -aG docker ec2-user

curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

sudo yum install -y nfs-utils
sudo mkdir /mnt/efs
echo "fs-0e23f87bdba2182bd.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs defaults 0 0" >> /etc/fstab
mount -a

sudo yum install -y mysql

sudo mkdir /Docker

sudo tee /Docker/docker-compose.yml <<EOF
version: '3.7'

services:
  wordpress:
    image: wordpress
    restart: always
    ports:
      - 80:80
    environment:
      WORDPRESS_DB_HOST: wordpress.c7djeexh6rth.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: admin
      WORDPRESS_DB_PASSWORD: wordpress
    volumes: 
      - /mnt/efs:/var/www/html
EOF

cd /Docker

docker-compose up -d

