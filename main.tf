provider "azurerm" {
  features {}
  use_msi = true
  subscription_id = "eeae8ca6-4e89-4182-b885-937dd6251ff3"
  tenant_id       = "a821faec-cd05-4ecf-a7d8-eba7eee014bd"
}


# Define the resource group
resource "azurerm_resource_group" "example" {
  name     = "rg-sandbox-lab-nurhaziqah-01"
  location = "Southeast Asia"
}

# Define the virtual network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-azure-test"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Define the subnet
resource "azurerm_subnet" "example" {
  name                 = "subnet-azure-test"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Define the network interface
resource "azurerm_network_interface" "example" {
  name                = "nic-azure-test"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Define the user-assigned Managed Identity
resource "azurerm_user_assigned_identity" "example" {
  name                = "managed-identity-azure-test"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Define the virtual machine
resource "azurerm_virtual_machine" "example" {
  name                  = "vm-azure-test"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_D2s_v5"

  storage_os_disk {
    name              = "vm-azure-test_OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter-Azure-Edition"
    version   = "latest"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "adminuser"
    admin_password = "Adminuser@1234567890"
  }

  os_profile_windows_config {
    provision_vm_agent = true
    enable_automatic_upgrades = true
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }
}
