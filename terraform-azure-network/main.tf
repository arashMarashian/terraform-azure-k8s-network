terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  vnet_name   = "${var.resource_group_name}-vnet"
  subnet_name = "${var.resource_group_name}-snet-k8s"
  nsg_name    = "${var.resource_group_name}-nsg-k8s"
}

# 1) Resource Group (West Europe / westeurope by default)
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# 2) Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = ["10.0.0.0/16"]
}

# 3) Subnet for Kubernetes nodes
resource "azurerm_subnet" "k8s_nodes" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.0.1.0/24"]
}

# 4) Network Security Group with 2 inbound rules
resource "azurerm_network_security_group" "k8s_nsg" {
  name                = local.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Allow HTTPS (443) from the internet
  security_rule {
    name                       = "Allow-HTTPS-Internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow Kubernetes API (6443) from office IP range only
  security_rule {
    name                       = "Allow-K8sAPI-Office"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = var.office_ip_range
    destination_address_prefix = "*"
  }
}

# 5) Associate NSG to Subnet
resource "azurerm_subnet_network_security_group_association" "k8s_assoc" {
  subnet_id                 = azurerm_subnet.k8s_nodes.id
  network_security_group_id = azurerm_network_security_group.k8s_nsg.id
}
