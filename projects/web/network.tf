data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket         = "terraform-state.common.osamaoracle.com"
    key            = "state/network"
    region         = "eu-west-1"
  }
}

resource "aws_security_group" "nginx-80" {
  name        = "nginx-80"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc.vpc_id

  ingress {
    description = "80 from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.this.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-80"
  }
}
