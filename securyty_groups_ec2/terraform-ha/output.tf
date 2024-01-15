output "public_dns" {
  value = local.public_key
}

output "connect_via_ssh" {
  value = "ssh -i ~/.ssh/${module.key_module.key_name} ec2-user@${local.public_key}"
}

output "external_instance_name" {
  value = data.aws_instance.name.tags["Name"]
}