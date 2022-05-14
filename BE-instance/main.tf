resource "aws_instance" "be-instance" {
  ami           = "ami-0022f774911c1d690"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name      = "instance-key"
  subnet_id     = "${element(split(",", data.aws_ssm_parameter.web_id.value), 0)}"
  security_groups = [ "${data.aws_ssm_parameter.instance-sg-id.value}" ]
  tags = {
    Name = "be-instance"
  }
}
 
resource "aws_eip" "elasticip2"{
  instance = aws_instance.be-instance.id
}

resource "null_resource" "connection2"  {

	connection {
		type     = "ssh"
		user     = "ec2-user"
		private_key = data.aws_ssm_parameter.private-key.value
		host     =  aws_eip.elasticip2.public_ip
	}	
	
// Mounting the EFS on the folder /var/www/html and pulling the code from github


 provisioner "remote-exec" {
      inline = [
        "sudo yum install httpd git -y",
        "sudo systemctl restart httpd",
        "sudo systemctl enable --now httpd",
        "echo 'hello World' > /var/www/index.html",
        "sudo yum install -y amazon-efs-utils",
        "sudo echo ${data.aws_ssm_parameter.efs-dns-name.value}:/home/ec2-user efs defaults,_netdev 0 0 >> sudo /etc/fstab",
        "sudo mount  ${data.aws_ssm_parameter.efs-dns-name.value}:/home/ec2-user",
        "sudo rm -rf /etc/yum.repos.d/nodesource-el*",
        "sudo curl -sL https://rpm.nodesource.com/setup_16.x | sudo -E bash -",
        "sudo yum install -y nodejs --enablerepo=nodesource",
        "sudo npm install -y pm2 -g",
//        "npm install -y",
  //      "sudo pm2 start src/index.js"
    ]
    
  }
  
    triggers= {
    always_run = "${timestamp()}"
  }
}

