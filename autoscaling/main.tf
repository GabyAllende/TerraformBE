resource "aws_security_group" "upb_load_balancer_sg" {
  name        = "upb-load-balancer-sg"
  vpc_id      = data.aws_ssm_parameter.vpc_id_parameter.value

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  tags = {
    Name = "upb-load-balancer-sg"
  }
}

resource "aws_security_group" "upb_instance_sg" {
  name        = "upb-instance-sg"
  vpc_id      = data.aws_ssm_parameter.vpc_id_parameter.value

  ingress {
    description      = "http traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
 
  tags = {
    Name = "upb-instance-sg"
  }
}
