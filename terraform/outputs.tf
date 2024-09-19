output "master_public_ip" {
  value = aws_instance.master.public_ip
  description = "Public IP address of the master instance"
}

output "worker_public_ips" {
  value = aws_instance.worker.*.public_ip
  description = "Public IP addresses of the worker instances"
}