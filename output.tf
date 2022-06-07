output "ips1" {
  value = ["${join(",", aws_instance.consul_server_1.*.public_ip)}"]
}

output "ips2" {
  value = ["${join(",", aws_instance.consul_server_2.*.public_ip)}"]
}

output "ips3" {
  value = ["${join(",", aws_instance.consul_server_3.*.public_ip)}"]
}

output "Consul_UI" {
  value = "${aws_elb.consulelb.dns_name}:8500"
}

