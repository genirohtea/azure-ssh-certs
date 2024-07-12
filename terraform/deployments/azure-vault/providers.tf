terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  # Opentofu encrypted state
  # https://opentofu.org/docs/language/state/encryption/
  encryption {
    key_provider "pbkdf2" "key" {
      # Specify a long / complex passphrase (min. 16 characters)
      passphrase = var.state_passphrase

      # Adjust the key length to the encryption method (default: 32)
      key_length = 32

      # Specify the number of iterations (min. 200.000, default: 600.000)
      iterations = 600000

      # Specify the salt length in bytes (default: 32)
      salt_length = 32

      # Specify the hash function (sha256 or sha512, default: sha512)
      hash_function = "sha512"
    }

    method "aes_gcm" "encrypt_method" {
      keys = key_provider.pbkdf2.key
    }

    state {
      # Encryption/decryption for state data
      method = method.aes_gcm.encrypt_method
    }

    plan {
      # Encryption/decryption for plan data
      method = method.aes_gcm.encrypt_method
    }

    remote_state_data_sources {
      # See below
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}
