resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  egress {
    description      = "Allow full output"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "allow_http"
    },
  )
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "example_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.pub_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  user_data = <<USER_DATA
#!/bin/bash
sudo apt update
sudo apt install -y nodejs npm
sudo mkdir /app
sudo chown -R $(id -u):$(id -g) /app
cd /app
npm init -y
npm i express@4.18.2
npm i pg@8.8.0
echo "${filebase64("${path.module}/nodejs-app-crud.service")}" | base64 -d > /lib/systemd/system/nodejs-app-crud.service
echo "${filebase64("${path.module}/nodejs-app-crud.js")}" | base64 -d > /app/nodejs-app-crud.js
echo "${filebase64("${path.module}/nodejs-app-crud-emails.js")}" | base64 -d > /app/nodejs-app-crud-emails.js
echo "{\"port\": 80, \"postgres\": {\"host\": \"localhost\", \"port\": 5432, \"database\": \"crud\", \"user\": \"ubuntu\", \"password\": \"ubuntu\"}}" > nodejs-app-crud-config.json
# Why use setcap? See this page on stackoverflow https://stackoverflow.com/a/60373143
sudo apt-get install -y libcap2-bin
sudo setcap cap_net_bind_service=+ep `readlink -f \`which node\``
sudo systemctl start nodejs-app-crud
sudo systemctl enable nodejs-app-crud
# PostgreSQL
sudo apt install postgresql -y
sudo -u postgres bash -c 'psql -U postgres -c "CREATE ROLE ubuntu;"'
sudo -u postgres bash -c 'psql -U postgres -c "ALTER ROLE  ubuntu  WITH LOGIN;"'
sudo -u postgres bash -c 'psql -U postgres -c "ALTER ROLE  ubuntu  WITH SUPERUSER;"'
echo "ALTER USER  ubuntu WITH PASSWORD 'ubuntu'" | sudo -u postgres bash -c "psql -U postgres"
sudo -u postgres bash -c 'psql -U postgres -c "CREATE DATABASE crud;"'
export PGPASSWORD=ubuntu
psql -h 127.0.0.1 -U ubuntu -d crud -c "CREATE TABLE emails (ID SERIAL PRIMARY KEY, name VARCHAR(30), email VARCHAR(30));"
USER_DATA

  tags = merge(
    var.tags,
    {
      Name = "CRUD Example"
    },
  )
}
