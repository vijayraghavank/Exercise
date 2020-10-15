provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x.
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
}

resource "azurerm_resource_group" "azure_rg" {
  name     =  var.rgname
  location =  var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
    name                 = var.vnet_name
    address_space        = var.address_space
    location             = var.location
    resource_group_name  = var.rgname
    depends_on            = [azurerm_resource_group.azure_rg]
}
# Subnet for virtual machine
resource "azurerm_subnet" "vmsubnet" {
  name                  =  var.subnet_name
  address_prefixes      =  var.address_prefixes
  virtual_network_name  =  var.vnet_name
  resource_group_name   =  var.rgname
  depends_on            = [azurerm_virtual_network.vnet,azurerm_resource_group.azure_rg]
}

# Add a Public IP address
resource "azurerm_public_ip" "vmip" {
    count                  = var.numbercount
    name                   = "vm-ip-${count.index}"
    resource_group_name    =  var.rgname
    allocation_method      = "Static"
    location               = var.location
    depends_on            = [azurerm_resource_group.azure_rg]
}

# Add a Network security group
resource "azurerm_network_security_group" "nsgname" {
    name                   = "vm-nsg"
    location               = var.location
    resource_group_name    =  var.rgname
    depends_on             = [azurerm_resource_group.azure_rg]

    security_rule {
        name                       = "PORT_SSH"
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
  }
}

#Associate NSG with  subnet
resource "azurerm_subnet_network_security_group_association" "nsgsubnet" {
    subnet_id                    = azurerm_subnet.vmsubnet.id
    network_security_group_id    = azurerm_network_security_group.nsgname.id
    depends_on                   = [azurerm_resource_group.azure_rg]
}

# NIC with Public IP Address
resource "azurerm_network_interface" "terranic" {
    count                  = var.numbercount
    name                   = "vm-nic-${count.index}"
    location               = var.location
    resource_group_name    =  var.rgname
    depends_on            = [azurerm_resource_group.azure_rg]

    ip_configuration {
        name                          = "external"
        subnet_id                     = azurerm_subnet.vmsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = element(azurerm_public_ip.vmip.*.id, count.index)
  }

}

#Data Disk for Virtual Machine
resource "azurerm_managed_disk" "datadisk" {
 count                = var.numbercount
 name                 = "datadisk_existing_${count.index}"
 location             = var.location
 resource_group_name  = var.rgname
 storage_account_type = "Standard_LRS"
 create_option        = "Empty"
 disk_size_gb         = "50"
 depends_on           = [azurerm_resource_group.azure_rg]
}

#Aure Virtual machine
resource "azurerm_virtual_machine" "terravm" {
    name                  = "vm-stg-${count.index}"
    location              = var.location
    resource_group_name   = var.rgname
    count 		  = var.numbercount
    network_interface_ids = [element(azurerm_network_interface.terranic.*.id, count.index)]
    vm_size               = "Standard_B1ls"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true
    depends_on            = [azurerm_resource_group.azure_rg]


storage_os_disk {
    name                 = "osdisk-${count.index}"
    caching              = "ReadWrite"
    create_option        = "FromImage"
    managed_disk_type    = "Premium_LRS"
    disk_size_gb         = "30"
  }

 storage_data_disk {
   name              = element(azurerm_managed_disk.datadisk.*.name, count.index)
   managed_disk_id   = element(azurerm_managed_disk.datadisk.*.id, count.index)
   create_option     = "Attach"
   lun               = 1
   disk_size_gb      = element(azurerm_managed_disk.datadisk.*.disk_size_gb, count.index)
 }

   storage_image_reference {
    publisher       = "Canonical"
    offer           = "UbuntuServer"
    sku             = "16.04-LTS"
    version         = "latest"
  }
  os_profile {
        computer_name  = "hostname"
        admin_username = "vijay"
        admin_password = "password123!"
    }

    os_profile_linux_config {
      disable_password_authentication = false

        ssh_keys {
        path     = "/home/vijay/.ssh/authorized_keys"
        key_data = file("~/.ssh/id_rsa.pub")
 }
    }

   connection {
        host = azurerm_public_ip.admingwip.id
        user = "vijay"
        type = "ssh"
        private_key = file("~/.ssh/id_rsa")
        timeout = "1m"
        agent = true
  }
}

