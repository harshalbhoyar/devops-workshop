# output "ec2_global_ips" {
#   value = ["${aws_instance.test-instance.*.public_ip}"]
# }

output "instance_public_ips" {
  description = "Public IPs of the EC2 instances"
  value       = { for instance in aws_instance.demo-server : instance.tags["Name"] => instance.public_ip }
}