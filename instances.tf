# server-1
resource "aws_instance" "consul_server_1" {
  ami                    = "ami-0b898040803850657"
  instance_type          = "t2.micro"
  availability_zone      = var.region_azs.az1
  count                  = "1"
  key_name               = var.key_name
  vpc_security_group_ids = ["${aws_security_group.consul.id}", "${aws_security_group.consul_internet_access.id}"]
  subnet_id              = aws_subnet.consul_1.id

  provisioner "remote-exec" {
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = var.user
      private_key = file(var.priv_key_path)
      agent       = "false"
    }

    inline = [
      "sudo amazon-linux-extras install docker -y && sudo systemctl start docker && sudo systemctl enable docker",
      "sudo docker run -d --net=host --hostname 'consul-server-1' --name 'consul-server-1' --env 'SERVICE_IGNORE=true' --env 'CONSUL_CLIENT_INTERFACE=eth0' --env 'CONSUL_BIND_INTERFACE=eth0' --volume /home/ubuntu/consul/data:/consul/data --volume /home/ubuntu/consul/config:/consul/config --publish 8500:8500 consul:latest consul agent -server -ui -client=0.0.0.0 -bootstrap-expect=3 -advertise=${self.private_ip} -data-dir='/consul/data'",
      "sudo docker run -d --name=registrator --net=host --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest consul://${self.private_ip}:8500",
      "sleep 5",
      "sudo docker logs consul-server-1",
      "sudo docker exec -i consul-server-1 consul members",
    ]
  }
  tags = {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "consul-server-1"
  }
}

# server-2
resource "aws_instance" "consul_server_2" {
  ami                    = "ami-0b898040803850657"
  instance_type          = "t2.micro"
  availability_zone      = var.region_azs.az2
  count                  = "1"
  depends_on             = ["aws_instance.consul_server_1"]
  key_name               = var.key_name
  vpc_security_group_ids = ["${aws_security_group.consul.id}", "${aws_security_group.consul_internet_access.id}"]
  subnet_id              = aws_subnet.consul_2.id

  provisioner "remote-exec" {
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = var.user
      private_key = file(var.priv_key_path)
      agent       = "false"
    }

    inline = [
      "sudo amazon-linux-extras install docker -y && sudo systemctl start docker && sudo systemctl enable docker",
      "sudo docker run -d --net=host --hostname 'consul-server-2' --name 'consul-server-2' --env 'SERVICE_IGNORE=true' --env 'CONSUL_CLIENT_INTERFACE=eth0' --env 'CONSUL_BIND_INTERFACE=eth0' --volume /home/ubuntu/consul/data:/consul/data --volume /home/ubuntu/consul/config:/consul/config --publish 8500:8500 consul:latest consul agent -server -ui -client=0.0.0.0 -advertise=${self.private_ip} -retry-join=${aws_instance.consul_server_1[count.index].private_ip} -data-dir='/consul/data'",
      "sudo docker run -d --name=registrator --net=host --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest consul://${self.private_ip}:8500",
      "sleep 5",
      "sudo docker logs consul-server-2",
      "sudo docker exec -i consul-server-2 consul members",
    ]
  }
  tags = {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "consul-server-2"
  }
}


# server-3
resource "aws_instance" "consul_server_3" {
  ami                    = "ami-0b898040803850657"
  instance_type          = "t2.micro"
  availability_zone      = var.region_azs.az3
  count                  = "1"
  key_name               = var.key_name
  vpc_security_group_ids = ["${aws_security_group.consul.id}", "${aws_security_group.consul_internet_access.id}"]
  subnet_id              = aws_subnet.consul_3.id

  provisioner "remote-exec" {
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = var.user
      private_key = file(var.priv_key_path)
      agent       = "false"
    }

    inline = [
      "sudo amazon-linux-extras install docker -y && sudo systemctl start docker && sudo systemctl enable docker",
      "sudo docker run -d --net=host --hostname 'consul-server-3' --name 'consul-server-3' --env 'SERVICE_IGNORE=true' --env 'CONSUL_CLIENT_INTERFACE=eth0' --env 'CONSUL_BIND_INTERFACE=eth0' --volume /home/ubuntu/consul/data:/consul/data --volume /home/ubuntu/consul/config:/consul/config --publish 8500:8500 consul:latest consul agent -server -ui -client=0.0.0.0 -advertise=${self.private_ip} -retry-join=${aws_instance.consul_server_1[count.index].private_ip} -data-dir='/consul/data'",
      "sudo docker run -d --name=registrator --net=host --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest consul://${self.private_ip}:8500",
      "sleep 5",
      "sudo docker logs consul-server-3",
      "sudo docker exec -i consul-server-3 consul members"
    ]
  }
  tags = {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "consul-server-3"
  }
}

# Public Frontend ELB
resource "aws_elb" "consulelb" {
  name            = "elb-public-frontend"
  subnets         = ["${aws_subnet.consul_1.id}", "${aws_subnet.consul_2.id}", "${aws_subnet.consul_3.id}"]
  security_groups = ["${aws_security_group.consul.id}", "${aws_security_group.consul_internet_access.id}"]
  listener {
    instance_port     = 8500
    instance_protocol = "http"
    lb_port           = 8500
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8500"
    interval            = 30
  }
}

resource "aws_elb_attachment" "consulelb1" {
  elb      = aws_elb.consulelb.id
  instance = element(aws_instance.consul_server_1.*.id, 0)
}
resource "aws_elb_attachment" "consulelb2" {
  elb      = aws_elb.consulelb.id
  instance = element(aws_instance.consul_server_2.*.id, 0)
}
resource "aws_elb_attachment" "consulelb3" {
  elb      = aws_elb.consulelb.id
  instance = element(aws_instance.consul_server_3.*.id, 0)
}
