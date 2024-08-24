 resource "aws_elasticache_replication_group" "replication_group" {
  count = var.enable_redis_cluster ? 1 : 0
  replication_group_id = "${var.redis_cluster_name}"
  node_type         = "cache.t3.micro"
  engine            = "redis"
  engine_version       = "7.0"
  automatic_failover_enabled = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token  = var.redis_auth_token != "" ? var.redis_auth_token : null
  apply_immediately = true
  port              = 6379
  num_node_groups         = 1
  replicas_per_node_group = 2
  description = var.redis_cluster_name
  subnet_group_name = "${aws_elasticache_subnet_group.redis_subnet_group.name}"
  security_group_ids = ["${aws_security_group.redis_sg.id}"]
  log_delivery_configuration {
  destination      = aws_cloudwatch_log_group.elastic_log_group.name
  destination_type = "cloudwatch-logs"
  log_format       = "text"
  log_type         = "slow-log"
  }

  parameter_group_name = "${aws_elasticache_parameter_group.parameter_group.name}"
  snapshot_window = "17:00-18:00"
  maintenance_window = "sun:05:00-sun:09:00"
  auto_minor_version_upgrade = true
  tags = {
    "Name" = "${var.redis_cluster_name}"
  }
}


resource "aws_elasticache_parameter_group" "parameter_group" {
  name   = "${var.redis_cluster_name}-parameter-group"
  family = "redis7"
}



resource "aws_cloudwatch_log_group" "elastic_log_group" {
  name = "${var.redis_cluster_name}_log"

  tags = {
    Environment = "${var.environment}"
    Application = "${var.redis_cluster_name}_Application"
  }
}



resource "aws_security_group" "redis_sg" {
  name        = "${var.redis_cluster_name}_sg"
  description = "Redis security group"
  vpc_id     = aws_vpc.vpc-tf.id

 ingress {
    description      = "Traffic from vpc cidr"
    from_port        = 6379
    to_port          = 6379
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}


resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${var.redis_cluster_name}-subnet-group"
  subnet_ids = flatten(["${aws_subnet.vpc-tf-public-subnets.*.id}"])
  description = "${var.redis_cluster_name}-subnet-group"
 
}