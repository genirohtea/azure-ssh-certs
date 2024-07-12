output "vault_name" {
  value = azurerm_key_vault.vault.name
}

output "vault_tenant_id" {
  value = azurerm_key_vault.vault.tenant_id
}

output "vault_id" {
  value = azurerm_key_vault.vault.id
}

output "userca_key_openssh_pub" {
  value = tls_private_key.userca-key.public_key_openssh
}

output "hostca_key_openssh_pub" {
  value = tls_private_key.hostca-key.public_key_openssh
}

output "rotation_date" {
  value = time_static.rotate
}

output "expiration_date" {
  value = timeadd(time_rotating.key_rotation_interval.rotation_rfc3339, "720h")
}
