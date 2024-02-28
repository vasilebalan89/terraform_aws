output "vm_passwords" {
  value     = random_password.password.*.result
  sensitive = true
}

output "instance_public_ips" {
  value = aws_instance.vm.*.public_ip
}

output "instance_private_ips" {
  value = aws_instance.vm.*.private_ip
}

