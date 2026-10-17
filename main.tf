# ============================================================================
#  Examen Practico 1 - Unidad 1
#  UTVT - Terraform + Azure
# ============================================================================
#
#  NOTA IMPORTANTE sobre los rangos (valores de la tabla del examen):
#  Los rangos de la tabla NO son desplegables en Azure:
#    - "10.0.1.0/18" -> Azure lo rechaza (InvalidCIDRNotation). El prefijo
#      debe ser la direccion de red; deberia ser 10.0.0.0/18, que ademas
#      se solaparia con TODO lo demas.
#    - "10.0.2.0/23" -> se solapa con la subred vm 10.0.3.0/27.
#  Se conservan las direcciones (10.0.1/10.0.2/10.0.3/10.0.4) pero con
#  prefijos validos y sin solape:
#    app 10.0.1.0/24 | db 10.0.2.0/24 | vm 10.0.3.0/27 | pe 10.0.4.0/29
# ============================================================================

# ---------------------------------------------------------------------------
# 1. Resource Group
# ---------------------------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    entorno = "dev"
    proyecto = "utvt-integradora"
  }

  lifecycle {
    # Seguridad: nunca destruir el RG (contiene el proyecto integradora)
    prevent_destroy = true
    # No tocar las etiquetas existentes del RG
    ignore_changes = [tags]
  }
}

# ---------------------------------------------------------------------------
# 2. Red Virtual
# ---------------------------------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = var.vnet_location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space

  tags = {
    entorno = "dev"
  }
}

# ---------------------------------------------------------------------------
# 3. Subred - Integracion de App Service (delegada a Microsoft.Web/serverFarms)
#    Recibe siempre la primera subred creada en el VNet.
# ---------------------------------------------------------------------------
resource "azurerm_subnet" "app" {
  name                 = "snet-utvt-examen-app-dev-mxc-001"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "delegation-app-service"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}

# ---------------------------------------------------------------------------
# 4. Subred - Base de datos (reservada)
# ---------------------------------------------------------------------------
resource "azurerm_subnet" "db" {
  name                 = "snet-utvt-examen-db-dev-mxc-001"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# ---------------------------------------------------------------------------
# 5. Subred - Maquina virtual
# ---------------------------------------------------------------------------
resource "azurerm_subnet" "vm" {
  name                 = "snet-utvt-examen-vm-dev-mxc-001"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/27"]
}

# ---------------------------------------------------------------------------
# 6. Subred - Private Endpoints
#    Requiere deshabilitar las politicas de red para private endpoints.
# ---------------------------------------------------------------------------
resource "azurerm_subnet" "pe" {
  name                              = "snet-utvt-examen-pe-dev-mxc-001"
  resource_group_name               = azurerm_resource_group.rg.name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  address_prefixes                  = ["10.0.4.0/29"]
  private_endpoint_network_policies = "Disabled"
}


