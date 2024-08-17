
variable "state_passphrase" {
  type        = string
  description = "The passphrase to encrypt the state with"
  sensitive   = true
}

######

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

variable "access_token" {
  type        = string
  description = "The access token to use for authentication."
  default     = null
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
