### Storage + Resource Group
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "vault_rg" {
  name     = "rg-${var.service}-${terraform.workspace}-${var.site}"
  location = var.resource_group_location

  tags = {
    environment             = terraform.workspace
    service                 = var.service
    site                    = var.site
    cloud_physical_location = var.resource_group_location
  }
}

# Lock the resource group to prevent others from editing it
resource "azurerm_management_lock" "resource_group_lock" {
  name       = "rgl-${var.service}-${terraform.workspace}-${var.site}"
  scope      = resource.azurerm_resource_group.vault_rg.id
  lock_level = "CanNotDelete"
}

# Create a storage account for storing the audit logs
resource "azurerm_storage_account" "vault_logs_account" {
  name                = "st${var.service}${terraform.workspace}${var.site}"
  resource_group_name = azurerm_resource_group.vault_rg.name

  location                        = azurerm_resource_group.vault_rg.location
  account_tier                    = "Standard"
  account_replication_type        = "GRS" # 11 nines of availability within a datacenter
  account_kind                    = "BlobStorage"
  min_tls_version                 = "TLS1_2" # Highest security
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  blob_properties {
    last_access_time_enabled = true
    delete_retention_policy {
      days = 7
    }
  }

  # Change SAS tokens to be short lived since we will never use them
  sas_policy {
    expiration_period = "1.00:00:00"
    expiration_action = "Log"
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["Logging", "Metrics", "AzureServices"]
  }

  tags = {
    environment             = terraform.workspace
    service                 = var.service
    site                    = var.site
    cloud_physical_location = var.resource_group_location
  }
}

# Set a log retention policy
resource "azurerm_storage_management_policy" "vault_logs_retention_policy" {
  storage_account_id = azurerm_storage_account.vault_logs_account.id

  rule {
    name    = "log_retention"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      # The data in this key vault will be accessed rarely and latency < 5s does not matter
      base_blob {
        tier_to_cold_after_days_since_last_access_time_greater_than = 1
        delete_after_days_since_modification_greater_than           = 545
      }
      snapshot {
        tier_to_cold_after_days_since_creation_greater_than = 1
        delete_after_days_since_creation_greater_than       = 545
      }
      version {
        tier_to_cold_after_days_since_creation_greater_than = 1
        delete_after_days_since_creation                    = 545
      }
    }
  }
}

##### Vault Creation


locals {
  current_user_id = coalesce(var.msi_id, data.azurerm_client_config.current.object_id)
}

resource "azurerm_key_vault" "vault" {
  # Must be globally unique
  name                = "kv-${var.service}-${terraform.workspace}-${var.site}"
  location            = var.resource_group_location
  resource_group_name = resource.azurerm_resource_group.vault_rg.name

  # Which tenant ID for authenticating requests? Use the tenant ID of the azure CLI user
  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = "standard"

  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  access_policy {
    # Set access policy for this user
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = local.current_user_id

    key_permissions         = var.key_permissions
    secret_permissions      = var.secret_permissions
    certificate_permissions = var.certificate_permissions
  }

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["0.0.0.0/0"]
  }

  tags = {
    environment             = terraform.workspace
    service                 = var.service
    site                    = var.site
    cloud_physical_location = var.resource_group_location
  }
}

// Enable logging for this vault
resource "azurerm_monitor_diagnostic_setting" "vault_logging" {
  name               = "kvd-${var.service}-${terraform.workspace}-${var.site}"
  target_resource_id = azurerm_key_vault.vault.id
  storage_account_id = azurerm_storage_account.vault_logs_account.id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
  }
}

##### Key Creation

resource "time_rotating" "key_rotation_interval" {
  rotation_years = 1
}

resource "time_static" "rotate" {
  # Changes when the key is rotated
  rfc3339 = time_rotating.key_rotation_interval.id
}


# RSA key of size 4096 bits
resource "tls_private_key" "userca-key" {
  algorithm = var.key_type
  rsa_bits  = var.key_size
  lifecycle {
    replace_triggered_by = [
      time_static.rotate
    ]
  }
}

resource "tls_private_key" "hostca-key" {
  algorithm = var.key_type
  rsa_bits  = var.key_size
  lifecycle {
    replace_triggered_by = [
      time_static.rotate
    ]
  }
}

locals {
  key_comps = [
    { field_name = "private_key_openssh", field_key = "priopenssh" },
    { field_name = "private_key_pem", field_key = "pripem" },
    { field_name = "private_key_pem_pkcs8", field_key = "pripkcs8" },
    { field_name = "public_key_fingerprint_md5", field_key = "md5" },
    { field_name = "public_key_fingerprint_sha256", field_key = "sha256" },
    { field_name = "public_key_openssh", field_key = "pubopenssh" },
    { field_name = "public_key_pem", field_key = "pubpem" },
  ]

  userca_key_name = "kvk-${var.service}-${terraform.workspace}-${var.site}-userca"
  hostca_key_name = "kvk-${var.service}-${terraform.workspace}-${var.site}-hostca"
}

resource "azurerm_key_vault_secret" "userca-key" {
  count = length(local.key_comps)

  name         = format("%s-%s", local.userca_key_name, local.key_comps[count.index]["field_key"])
  value        = tls_private_key.userca-key[local.key_comps[count.index]["field_name"]]
  key_vault_id = azurerm_key_vault.vault.id
  content_type = local.key_comps[count.index]["field_name"]
  # 30 Day buffer on key expiration
  expiration_date = timeadd(time_rotating.key_rotation_interval.rotation_rfc3339, "720h")

  tags = {
    environment             = terraform.workspace
    service                 = var.service
    site                    = var.site
    cloud_physical_location = var.resource_group_location
  }
}


resource "azurerm_key_vault_secret" "hostca-key" {
  count = length(local.key_comps)

  name         = format("%s-%s", local.hostca_key_name, local.key_comps[count.index]["field_key"])
  value        = tls_private_key.hostca-key[local.key_comps[count.index]["field_name"]]
  key_vault_id = azurerm_key_vault.vault.id
  content_type = local.key_comps[count.index]["field_name"]
  # 30 Day buffer on key expiration
  expiration_date = timeadd(time_rotating.key_rotation_interval.rotation_rfc3339, "720h")


  tags = {
    environment             = terraform.workspace
    service                 = var.service
    site                    = var.site
    cloud_physical_location = var.resource_group_location
  }
}
