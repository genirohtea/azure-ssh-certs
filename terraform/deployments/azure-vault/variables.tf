
variable "state_passphrase" {
  type        = string
  description = "The passphrase to encrypt the state with"
  sensitive   = true
}

######

variable "resource_group_location" {
  type        = string
  description = "Location for all resources."
  default     = "eastus"
}

variable "service" {
  type        = string
  description = "The name of the service"
  default     = "sshcerts"
}

variable "site" {
  type        = string
  description = "The name of the site"
  default     = "klaus"
}


########

variable "msi_id" {
  type        = string
  description = "The Managed Service Identity ID. If this value isn't null (the default), 'data.azurerm_client_config.current.object_id' will be set to this value (the currently logged in azure user)."
  default     = null
}

# https://learn.microsoft.com/en-us/azure/key-vault/certificates/certificate-access-control
variable "certificate_permissions" {
  type        = list(string)
  description = "List of vault key permissions for the current azure user."
  default     = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
}

variable "key_permissions" {
  type        = list(string)
  description = "List of vault key permissions for the current azure user."
  default     = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
}

variable "secret_permissions" {
  type        = list(string)
  description = "List of vault secret permissions for the current azure user."
  default     = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
}


########

variable "key_type" {
  description = "The key type"
  default     = "RSA"
  type        = string
  validation {
    condition     = contains(["ECDSA", "RSA", "ED25519"], var.key_type)
    error_message = "The key_type must be one of the following: ECDSA, RSA, ED25519"
  }
}

variable "key_size" {
  type        = number
  description = "The size in bits of the key to be created."
  default     = 4096
}
