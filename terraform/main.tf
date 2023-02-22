###
# This example code creates an AKS cluster with no public endpoints
###

terraform {
  required_version = ">= 0.14"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.50.0"
    }
  }
}

provider "azurerm" {
  features {}
}

#local vars

locals {
  region          = "eastus"
  environment     = "test"
  name_prefix     = "private-aks"
  address_space   = ["10.200.0.0/16"]
  aks_node_prefix = ["10.200.0.0/24"]
  firewall_prefix = ["10.200.1.0/24"]
}

#resource group

resource "azurerm_resource_group" "base" {
  name     = "rg-${local.name_prefix}-${local.environment}-${local.region}"
  location = local.region
}

#vnet

resource "azurerm_virtual_network" "base" {
  name                = "vnet-${local.name_prefix}-${local.environment}-${local.region}"
  resource_group_name = azurerm_resource_group.base.name
  address_space       = local.address_space
  location            = azurerm_resource_group.base.location
}

#subnets

resource "azurerm_subnet" "aks" {
  name                 = "snet-${local.name_prefix}-${local.environment}-${local.region}"
  resource_group_name  = azurerm_resource_group.base.name
  address_prefixes     = local.aks_node_prefix
  virtual_network_name = azurerm_virtual_network.base.name
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.base.name
  virtual_network_name = azurerm_virtual_network.base.name
  address_prefixes     = local.firewall_prefix
}

#user assigned identity

resource "azurerm_user_assigned_identity" "base" {
  resource_group_name = azurerm_resource_group.base.name
  location            = azurerm_resource_group.base.location
  name                = "mi-${local.name_prefix}-${local.environment}-${local.region}"
}

#role assignment

resource "azurerm_role_assignment" "base" {
  scope                = azurerm_resource_group.base.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.base.principal_id
}

#route table

resource "azurerm_route_table" "base" {
  name                = "rt-${local.name_prefix}-${local.environment}-${local.region}"
  location            = azurerm_resource_group.base.location
  resource_group_name = azurerm_resource_group.base.name
}

#route 

resource "azurerm_route" "base" {
  name                   = "dg-${local.environment}-${local.region}"
  resource_group_name    = azurerm_resource_group.base.name
  route_table_name       = azurerm_route_table.base.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.base.ip_configuration.0.private_ip_address
}

#route table association

resource "azurerm_subnet_route_table_association" "base" {
  subnet_id      = azurerm_subnet.aks.id
  route_table_id = azurerm_route_table.base.id
}

#firewall

resource "azurerm_public_ip" "base" {
  name                = "pip-firewall"
  location            = azurerm_resource_group.base.location
  resource_group_name = azurerm_resource_group.base.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "base" {
  name                = "fw-${local.name_prefix}-${local.environment}-${local.region}"
  location            = azurerm_resource_group.base.location
  resource_group_name = azurerm_resource_group.base.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "ip-${local.name_prefix}-${local.environment}-${local.region}"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.base.id
  }
}

#kubernetes_cluster

resource "azurerm_kubernetes_cluster" "base" {
  name                    = "${local.name_prefix}-${local.environment}-${local.region}"
  location                = azurerm_resource_group.base.location
  resource_group_name     = azurerm_resource_group.base.name
  dns_prefix              = "dns-${local.name_prefix}-${local.environment}-${local.region}"
  private_cluster_enabled = true

  network_profile {
    network_plugin = "azure"
    outbound_type  = "userDefinedRouting"
  }


  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.aks.id
  }


  identity {
    type = "SystemAssigned"
  }
  
  depends_on = [
      azurerm_route.base,
      azurerm_role_assignment.base
    ]
}