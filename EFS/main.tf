resource "tls_private_key" p_key  {
  algorithm = "RSA"
}


resource "aws_key_pair" "instance-key" {
  key_name    = "instance-key"
  public_key = tls_private_key.p_key.public_key_openssh  
}

resource "aws_security_group" "instance-sg" {
  name        = "instance-sg"
  description = "Allow inbound traffic"
  vpc_id      = data.aws_ssm_parameter.vpc_id_parameter.value
 
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }


  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "instance-sg"
  }
 }
 
 resource "aws_security_group" "efs_sg" {
  depends_on = [
    aws_security_group.instance-sg,
  ]
  name        = "efs-sg"
  description = "Security group for efs storage"
  vpc_id      = data.aws_ssm_parameter.vpc_id_parameter.value
 


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.instance-sg.id]
  }
}

resource "aws_instance" "fe-instance" {
  ami           = "ami-0e306788ff2473ccb"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name      = "fe-key"
  security_groups = [ "efs-sg" ]
  
   connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key =  tls_private_key.p_key.private_key_pem
    host     = aws_instance.fe-instance.public_ip
 }


 provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
       "sudo yum install -y amazon-efs-utils"
    ]
  }


tags = {
       Name = "fe-inst"
  }
 }
 
 
 resource "aws_efs_file_system" "efs" {
  depends_on = [
    aws_security_group.efs_sg
  ]
  creation_token = "efs"
  tags = {
    Name = "storage"
  }
}


resource "aws_efs_mount_target" "efs_mount_0" {
  depends_on = [
    aws_efs_file_system.efs
  ]
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = "${element(split(",", data.aws_ssm_parameter.app_id.value), 0)}"
  security_groups = ["${aws_security_group.efs_sg.id}"]
}

resource "aws_efs_mount_target" "efs_mount_1" {
  depends_on = [
    aws_efs_file_system.efs
  ]
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = "${element(split(",", data.aws_ssm_parameter.app_id.value), 1)}"
  security_groups = ["${aws_security_group.efs_sg.id}"]
}

resource "aws_efs_mount_target" "efs_mount_2" {
  depends_on = [
    aws_efs_file_system.efs
  ]
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = "${element(split(",", data.aws_ssm_parameter.app_id.value), 2)}"
  security_groups = ["${aws_security_group.efs_sg.id}"]
}

resource "null_resource" "connection"  {
depends_on = [ aws_efs_mount_target.efs_mount_0,]


	connection {
		type     = "ssh"
		user     = "ec2-user"
		private_key = tls_private_key.p_key.private_key_pem
		host     = aws_instance.fe-instance.public_ip
	}	
	
// Mounting the EFS on the folder /var/www/html and pulling the code from github


 provisioner "remote-exec" {
      inline = [
        "sudo echo ${aws_efs_file_system.efs.dns_name}:/var/www/html efs defaults,_netdev 0 0 >> sudo /etc/fstab",
        "sudo mount  ${aws_efs_file_system.efs.dns_name}:/  /var/www/html",
        "sudo git clone https://github.com/Priyanshi541/HTask2.git /var/www/html/",
    ]
  }
}