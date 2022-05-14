data "aws_ssm_parameter" "vpc_id_parameter" { # data.aws_ssm_parameter.vpc_id_parameter.value
  name = "/vpc/id"
}
data "aws_ssm_parameter" "app_id" { # data.aws_ssm_parameter.vpc_id_parameter.value
  name = "/subnet/app/id"
}

data "aws_ssm_parameter" "web_id" { # data.aws_ssm_parameter.vpc_id_parameter.value
  name = "/subnet/web/id"
}

data "aws_ssm_parameter" "instance-sg-id" { # data.aws_ssm_parameter.vpc_id_parameter.value
  name = "/instance-sg/id"
}
data "aws_ssm_parameter" "efs-dns-name" { # data.aws_ssm_parameter.vpc_id_parameter.value
  name = "/efs-dns/name"
}

data "aws_ssm_parameter" "private-key" { # data.aws_ssm_parameter.vpc_id_parameter.value
  name = "/private-key"
}