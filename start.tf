# ---------------------------------------------------------------
# Providers
# ---------------------------------------------------------------


provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "rgw4" {
  name     = "ResourceGroupWeek4"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vn" {
  name                = "VirtualNetworkWeek4"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rgw4.location
  resource_group_name = azurerm_resource_group.rgw4.name
}

resource "azurerm_subnet" "snet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rgw4.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "interface" {
  name                = "example-nic"
  location            = azurerm_resource_group.rgw4.location
  resource_group_name = azurerm_resource_group.rgw4.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.rgw4.name
  location            = azurerm_resource_group.rgw4.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "Endava!2023"
  network_interface_ids = [
    azurerm_network_interface.interface.id,
  ]

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
