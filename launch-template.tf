resource "aws_security_group" "security_group_ecs" {
 name   = "ecs-security-group"
 vpc_id = aws_vpc.vpc-tf.id

 ingress {
   from_port   = 0
   to_port     = 0
   protocol    = -1
   self        = "false"
   cidr_blocks = ["0.0.0.0/0"]
   description = "any"
 }
  egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }

}


resource "aws_launch_template" "cluster_worker_node_launch_config" {
  name =  "${var.ecs_ec2_server}"
  image_id  = "ami-0e670eb768a5fc3d4"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      delete_on_termination = true
      volume_type = "gp2"
    }
  }
  instance_type = "t2.micro"
  network_interfaces {
    security_groups = [aws_security_group.security_group_ecs.id]
  }
#   user_data = base64encode(<<-EOF
# MIME-Version: 1.0
# Content-Type: multipart/mixed; boundary="==7561478f-5b81-4e9d-9db6-aec8f463d2ab=="


# --==7561478f-5b81-4e9d-9db6-aec8f463d2ab==
# Content-Type: text/x-shellscript; charset="us-ascii"


# #!/bin/bash
# sed -i '/^KUBELET_EXTRA_ARGS=/a KUBELET_EXTRA_ARGS+=" --register-with-taints=author=shishir:NoSchedule,creator=shishir:NoSchedule"' /etc/eks/bootstrap.sh


# --==7561478f-5b81-4e9d-9db6-aec8f463d2ab==--\
#   EOF
#   )
}
