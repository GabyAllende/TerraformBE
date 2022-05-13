data "aws_ssm_parameter" "vpc_id_parameter" { # data.aws_ssm_parameter.vpc_id_parameter.value
  name = "/vpc/id"
}
data "aws_ssm_parameter" "app_id" { # data.aws_ssm_parameter.vpc_id_parameter.value
  name = "/subnet/app/id"
}

data "aws_ssm_parameter" "web_id" { # data.aws_ssm_parameter.vpc_id_parameter.value
  name = "/subnet/web/id"
}