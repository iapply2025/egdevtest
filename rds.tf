
resource "random_password" "db" {
  length  = 16
  special = false
}

resource "aws_db_subnet_group" "db" {
  name       = "my-db-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "db_sg" {
  name   = "db-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "devops-test-db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "17.5"
  instance_class       = "db.t3.micro"
  db_name              = "devopstestdb"
  username             = "dbadmin"
  password             = random_password.db.result
  db_subnet_group_name = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot = true
}
