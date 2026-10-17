output "resource_group_name" {
  description = "Nombre del Resource Group creado"
  value       = azurerm_resource_group.rg.name
}

output "virtual_network_id" {
  description = "ID de la Red Virtual"
  value       = azurerm_virtual_network.vnet.id
}

output "subnets" {
  description = "IDs de las subredes creadas"
  value = {
    app = azurerm_subnet.app.id
    db  = azurerm_subnet.db.id
    vm  = azurerm_subnet.vm.id
    pe  = azurerm_subnet.pe.id
  }
}
