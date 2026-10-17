variable "location" {
  description = "Region de Azure del Resource Group existente"
  type        = string
  default     = "eastus"
}

variable "vnet_location" {
  description = "Region permitida por la politica de la suscripcion para la Red Virtual"
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Nombre del Resource Group"
  type        = string
  default     = "rg-utvt-integradora-dev-mxc-001"
}

variable "virtual_network_name" {
  description = "Nombre de la Red Virtual"
  type        = string
  default     = "vnet-utvt-examen-dev-mxc-001"
}

variable "vnet_address_space" {
  description = "Espacio de direcciones de la Red Virtual"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
