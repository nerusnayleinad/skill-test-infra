output "private_key_pem" {
  value = tls_private_key.bastion_key.private_key_pem
  sensitive = true
}