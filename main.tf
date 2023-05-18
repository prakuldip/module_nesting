# Get the current client configuration from the AzureRM provider.
# This is used to populate the root_parent_id variable with the
# current Tenant ID used as the ID for the "Tenant Root Group"
# Management Group.

data "azurerm_client_config" "core" {}

# Declare the Azure landing zones Terraform module
# and provide a base configuration.

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "4.0.1" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  default_location = "eastus"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm
    azurerm.management   = azurerm
  }

  root_parent_id = data.azurerm_client_config.core.tenant_id
  root_id        = var.root_id
  root_name      = var.root_name
  library_path   = "${path.root}/lib"

  custom_landing_zones = {
    "${var.root_id}-online-example-1" = {
      display_name               = "${upper(var.root_id)} Online Example 1"
      parent_management_group_id = "${var.root_id}-landing-zones"
      subscription_ids           = ["c771a68d-4f8b-4e76-be68-f8dbcd5872f1",]
      archetype_config = {
        archetype_id   = "customer_online"
        parameters     = {}
        access_control = {}
      }
    }
    "${var.root_id}-online-example-2" = {
      display_name               = "${upper(var.root_id)} Online Example 2"
      parent_management_group_id = "${var.root_id}-landing-zones"
      subscription_ids           = []
      archetype_config = {
        archetype_id = "customer_online"
        parameters = {
          Deny-Resource-Locations = {
            listOfAllowedLocations = ["eastus", ]
          }
          Deny-RSG-Locations = {
            listOfAllowedLocations = ["eastus", ]
          }
        }
        access_control = {}
      }
    }
  }
}

# Enterprise scale nested landing zone instance

module "enterprise_scale_nested_landing_zone" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "4.0.1" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  default_location = "eastus"
  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm
    azurerm.management   = azurerm
  }


  root_parent_id            = "${var.root_id}-landing-zones"
  root_id                   = var.root_id
  deploy_core_landing_zones = false
  library_path              = "${path.root}/lib"

  custom_landing_zones = {
    "${var.root_id}-module-instance" = {
      display_name               = "${upper(var.root_id)} Online Example 3 (nested)"
      parent_management_group_id = "${var.root_id}-landing-zones"
      subscription_ids           = ["bee810ca-7121-40a1-8465-71ec3b0d7449",]
      archetype_config = {
        archetype_id   = "customer_online"
        parameters     = {}
        access_control = {}
      }
    }
  }

  depends_on = [
    module.enterprise_scale,
  ]

}
