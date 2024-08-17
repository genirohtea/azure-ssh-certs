output "project_name" {
  value = var.site
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

output "all_projects" {
  value     = data.bitwarden-secrets_project_list.all_projects
  sensitive = true
}

output "matching_project" {
  value = local.project_id
}

output "userca_key_id" {
  value = bitwarden-secrets_secret.userca-key[5].id
}
output "userca_key_creation_date" {
  value = bitwarden-secrets_secret.userca-key[5].creation_date
}
output "userca_key_revision_date" {
  value = bitwarden-secrets_secret.userca-key[5].revision_date
}
output "hostca_key_id" {
  value = bitwarden-secrets_secret.hostca-key[5].id
}
output "hostca_key_creation_date" {
  value = bitwarden-secrets_secret.hostca-key[5].creation_date
}
output "hostca_key_revision_date" {
  value = bitwarden-secrets_secret.hostca-key[5].revision_date
}
