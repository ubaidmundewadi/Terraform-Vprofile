resource "aws_db_subnet_group" "vprofile-rds-subgrp" {
  name       = "vprofile-rds-subgrp"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  tags = {
    Name = "Subnet group for RDS"
  }
}

resource "aws_elasticache_subnet_group" "vprofile-elasticache-subgrp" {
  name       = "vprofile-elasticache-subgrp"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  tags = {
    Name = "Subnet group for Elasticache"
  }
}

resource "aws_db_instance" "vprofile-rds" {
  allocated_storage      = 20
  storage_type           = "gp2"
  identifier             = "vprofile-rds"
  db_subnet_group_name   = aws_db_subnet_group.vprofile-rds-subgrp.name
  engine                 = "mysql"
  engine_version         = "5.7.44"
  instance_class         = "db.t3.micro"
  multi_az               = false
  parameter_group_name   = "default.mysql5.7"
  db_name                = var.dbname
  password               = var.dbpass
  username               = var.dbuser
  publicly_accessible    = false
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.vprofile-backend-sg.id]
}

resource "aws_elasticache_cluster" "vprofile-cache" {
  cluster_id           = "vprofile-cache"
  engine               = "memcached"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
  security_group_ids   = [aws_security_group.vprofile-backend-sg.id]
  subnet_group_name    = aws_elasticache_subnet_group.vprofile-elasticache-subgrp.name
}

resource "aws_mq_broker" "vprofile-rmq" {
  broker_name        = "vprofile-rmq"
  engine_type        = "ActiveMQ"
  engine_version     = "5.16.7"
  host_instance_type = "mq.t2.micro"
  subnet_ids         = [module.vpc.private_subnets[0]]
  security_groups    = [aws_security_group.vprofile-backend-sg.id]
  user {
    password = var.rmqpass
    username = var.rmquser
  }
}