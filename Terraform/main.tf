provider "aws" {
  region = var.region
  profile = var.profile
}

#########################################
##            -- Key-pair --           ##
#########################################

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = var.key_name
  public_key = tls_private_key.this.public_key_openssh
}

#########################################
##        -- Security-Group --        ##
#########################################

resource "aws_security_group" "allow" {
  name        = var.security_group
  description = "Allow TLS inbound traffic"
  vpc_id      =  var.vpc_id
  

  ingress {
    description = "ssh"
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http"
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
    description = "https"
    from_port   = 0
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }   

  ingress {
    from_port   = 0
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

  ingress {
    from_port   = 0
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = var.security_group
  }
}

#########################################
##         -- Aws Instance --          ##
#########################################


resource "aws_instance" "web" {
  ami                  = var.ami
  instance_type  = var.instance_type
  key_name        = var.key_name
  vpc_security_group_ids =  [  aws_security_group.allow.id  ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.this.private_key_pem
    host     = aws_instance.web.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su <<END",
      "sudo su - root",
      "yum install httpd  php git -y",
      "systemctl restart httpd",
      "systemctl enable httpd",
       "END"
    ]
  }

  tags = {
    Name = var.instance_name
  }
}

#########################################
##           -- EBS Volume --          ##
#########################################

resource "aws_ebs_volume" "esb1" {
  availability_zone = aws_instance.web.availability_zone
  size              = 1
  tags = {
    Name = var.ebs
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   =  aws_ebs_volume.esb1.id
  instance_id =  aws_instance.web.id
  force_detach = true
}

resource "null_resource" "nullremote3"  {
depends_on = [
    aws_volume_attachment.ebs_att,
  ]
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.this.private_key_pem
    host     = aws_instance.web.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo su <<END",
      "sudo su - root",
      "mkfs.ext4  /dev/xvdh",
      "mount  /dev/xvdh  /var/www/html",
      "rm -rf /var/www/html/*",
      "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash",
      ". ~/.nvm/nvm.sh",
      "nvm install --lts",
      "git clone ${var.Github} /var/www/html/",
      "cd /var/www/html",
      "npm i",
      "node ${var.js_file}",
       "END"
    ]
  }
}
