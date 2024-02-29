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

resource "null_resource" "execute_script" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "./check_results.sh > completed.txt"
  }
}

output "script_output" {
  value = file("/root/DevOps/Project_Aws_Terraform/terraform_aws/completed.txt")
  depends_on = [null_resource.execute_script]
}
