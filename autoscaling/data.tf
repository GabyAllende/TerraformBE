data "aws_ssm_parameter" "vpc_id_parameter" { # data.aws_ssm_parameter.vpc_id_parameter.value
  name = "/vpc/id"
}
