data "azurerm_client_config" "current" {}

# 1. Enterprise Management Group Hierarchy
resource "azurerm_management_group" "root" {
  display_name = var.root_name
  name         = "${var.root_id}-root"
}

resource "azurerm_management_group" "platform" {
  display_name               = "Platform"
  name                       = "${var.root_id}-platform"
  parent_management_group_id = azurerm_management_group.root.id
}

resource "azurerm_management_group" "connectivity" {
  display_name               = "Connectivity"
  name                       = "${var.root_id}-platform-connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "management" {
  display_name               = "Management"
  name                       = "${var.root_id}-platform-management"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "identity" {
  display_name               = "Identity"
  name                       = "${var.root_id}-platform-identity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "landing_zones" {
  display_name               = "Landing Zones"
  name                       = "${var.root_id}-landing-zones"
  parent_management_group_id = azurerm_management_group.root.id
}

resource "azurerm_management_group" "corp" {
  display_name               = "Corp (Internal Only)"
  name                       = "${var.root_id}-lz-corp"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "online" {
  display_name               = "Online (Public DMZ)"
  name                       = "${var.root_id}-lz-online"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "sandbox" {
  display_name               = "Sandboxes"
  name                       = "${var.root_id}-sandboxes"
  parent_management_group_id = azurerm_management_group.root.id
}

# 2. Central Connectivity Hub VNet & Firewall
resource "azurerm_resource_group" "rg_connectivity" {
  name     = "rg-${var.root_id}-connectivity-hub"
  location = var.primary_location
  tags = {
    Role        = "HubConnectivity"
    Framework   = "CloudAdoptionFramework"
    Architect   = "Mohammad Sadique Qutub"
  }
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.primary_location}"
  resource_group_name = azurerm_resource_group.rg_connectivity.name
  location            = azurerm_resource_group.rg_connectivity.location
  address_space       = var.hub_address_space
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg_connectivity.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.firewall_subnet_prefix
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg_connectivity.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.gateway_subnet_prefix
}

resource "azurerm_public_ip" "fw_pip" {
  name                = "pip-afw-hub"
  location            = azurerm_resource_group.rg_connectivity.location
  resource_group_name = azurerm_resource_group.rg_connectivity.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall_policy" "fw_policy" {
  name                = "afwp-enterprise-hub"
  location            = azurerm_resource_group.rg_connectivity.location
  resource_group_name = azurerm_resource_group.rg_connectivity.name
  sku                 = "Premium"
  threat_intelligence_mode = "Deny"
}

resource "azurerm_firewall" "hub_fw" {
  name                = "afw-hub-${var.primary_location}"
  location            = azurerm_resource_group.rg_connectivity.location
  resource_group_name = azurerm_resource_group.rg_connectivity.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id

  ip_configuration {
    name                 = "afw-ipconfig"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
}

# 3. Workload Spoke Virtual Network
resource "azurerm_resource_group" "rg_spoke_corp" {
  name     = "rg-${var.root_id}-spoke-corp"
  location = var.primary_location
}

resource "azurerm_virtual_network" "spoke_corp" {
  name                = "vnet-spoke-corp-${var.primary_location}"
  resource_group_name = azurerm_resource_group.rg_spoke_corp.name
  location            = azurerm_resource_group.rg_spoke_corp.location
  address_space       = var.spoke_corp_address_space
}

resource "azurerm_virtual_network_peering" "hub_to_corp" {
  name                      = "peer-hub-to-corp"
  resource_group_name       = azurerm_resource_group.rg_connectivity.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke_corp.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "corp_to_hub" {
  name                      = "peer-corp-to-hub"
  resource_group_name       = azurerm_resource_group.rg_spoke_corp.name
  virtual_network_name      = azurerm_virtual_network.spoke_corp.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_route_table" "spoke_udr" {
  name                          = "rt-spoke-force-firewall"
  location                      = azurerm_resource_group.rg_spoke_corp.location
  resource_group_name           = azurerm_resource_group.rg_spoke_corp.name
  disable_bgp_route_propagation = false

  route {
    name                   = "DefaultRouteToFirewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hub_fw.ip_configuration[0].private_ip_address
  }
}
