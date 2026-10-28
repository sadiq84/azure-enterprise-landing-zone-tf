variable "root_id" {
  description = "Prefix identifier for the enterprise root management group."
  type        = string
  default     = "corp"
}

variable "root_name" {
  description = "Display name for the tenant root management group."
  type        = string
  default     = "Enterprise Cloud Root"
}

variable "primary_location" {
  description = "Primary Azure region for Hub deployment."
  type        = string
  default     = "eastus"
}

variable "hub_address_space" {
  description = "CIDR block for the Central Connectivity Hub VNet."
  type        = list(string)
  default     = ["10.100.0.0/16"]
}

variable "firewall_subnet_prefix" {
  description = "Subnet CIDR for Azure Firewall."
  type        = list(string)
  default     = ["10.100.2.0/24"]
}

variable "gateway_subnet_prefix" {
  description = "Subnet CIDR for ExpressRoute / S2S VPN Gateway."
  type        = list(string)
  default     = ["10.100.1.0/24"]
}

variable "spoke_corp_address_space" {
  description = "CIDR block for Corp Workloads Spoke VNet."
  type        = list(string)
  default     = ["10.101.0.0/16"]
}

variable "spoke_online_address_space" {
  description = "CIDR block for Online/DMZ Workloads Spoke VNet."
  type        = list(string)
  default     = ["10.102.0.0/16"]
}
