resource "aws_autoscaling_group" "ecs_asg" {
 vpc_zone_identifier = flatten(["${aws_subnet.vpc-tf-public-subnets.*.id}"])
 desired_capacity    = 2
 max_size            = 3
 min_size            = 1

 launch_template {
   id      = aws_launch_template.cluster_worker_node_launch_config.id
   version = "$Latest"
 }

 tag {
   key                 = "AmazonECSManaged"
   value               = true
   propagate_at_launch = true
 }
}