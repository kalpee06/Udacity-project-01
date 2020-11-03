# Specify the provider and access details
provider "azurerm" {
  features {}
}
# Create a Resource group and add tags
resource "azurerm_resource_group" "RG" {
  name     = var.resource_group
  location = var.location
  tags = {
    environment = var.environment
	department = var.department
  }
}
# Create a virtual network - vNet and add tags
resource "azurerm_virtual_network" "VNET" {
  name                = var.vnet_name
  address_space       = var.vnet_range
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  
  tags = {
    environment = var.environment
	department = var.department
  }
}
# Create subnet under virtual network
resource "azurerm_subnet" "SUBNET" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VNET.name
  address_prefixes     = var.subnet_range
}

# Create a Network Security Group - and add rules + tags
resource "azurerm_network_security_group" "NSG" {
  name                = "${var.vm_name}-nsg"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
    
 security_rule {
	name                       = "subNetTraffic"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

 security_rule {  
	name                       = "ExternalTraffic"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }
  tags = {
    environment = var.environment
	department = var.department
  }
}

# Create NSG association with Subnet
resource "azurerm_subnet_network_security_group_association" "NSG-association" {
  subnet_id					= azurerm_subnet.SUBNET.id
#  network_interface_id      = azurerm_network_interface.NIC.id
  network_security_group_id = azurerm_network_security_group.NSG.id
}


# Create a Network Interface Card and add tags
resource "azurerm_network_interface" "NIC" {
  count				  = var.num_of_vm
  name                = "${var.vm_name}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  
  ip_configuration {
    name                          = "${var.vm_name}-InternalIP-${count.index}"
    subnet_id                     = azurerm_subnet.SUBNET.id
    private_ip_address_allocation = "Dynamic"
#public_ip_address_id = element(azurerm_public_ip.vmip.*.id, count.index)	
	}
	tags = {
    environment = var.environment
	department = var.department
  }
}

# Create a Frontend Public IP address for association with Load Balancer and add tags
resource "azurerm_public_ip" "PIP" {
  name                = "${var.resource_group}-lb-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.RG.name
  allocation_method   = "Static"
  sku				  = "Standard"
  
  tags = {
    environment = var.environment
	department = var.department
  }
  
}
# Create backend address pool for Load Balancer
resource "azurerm_lb_backend_address_pool" "BkEndAddPool" {
  resource_group_name = azurerm_resource_group.RG.name
  loadbalancer_id     = azurerm_lb.LB.id
  name                = "${var.resource_group}-lb-backendaddresspool"
}

# Create a Load Balancer and assign frontend IP address and tags
resource "azurerm_lb" "LB" {
  name                = "${var.resource_group}-loadbalancer"
  location            = var.location
  resource_group_name = azurerm_resource_group.RG.name
  sku				  = "Standard"

  frontend_ip_configuration {
    name                 = "${var.resource_group}-lb-pip"
    public_ip_address_id = azurerm_public_ip.PIP.id
  }
  tags = {
    environment = var.environment
	department = var.department
  }
}

# Create a Load Balancer probe 
resource "azurerm_lb_probe" "Probe" {
  resource_group_name = azurerm_resource_group.RG.name
  loadbalancer_id     = azurerm_lb.LB.id
  name                = "ssh-running-probe"
  port                = 22
}

# Create a Inbound NAT pool for Load Balancer
resource "azurerm_lb_nat_pool" "NAT-pool" {
  #count		    				 = var.num_of_vm
  resource_group_name            = azurerm_resource_group.RG.name
  loadbalancer_id                = azurerm_lb.LB.id
  name							 = "${var.resource_group}-lb-NATpool"
  #name                           = "${var.resource_group}-lb-NATpool-${count.index}"
  protocol                       = "Tcp"
  frontend_port_start            = 1
  frontend_port_end              = 65534
  backend_port                   = 22
  frontend_ip_configuration_name = "${var.resource_group}-lb-pip"
}

# Create a Load Balancer rule
resource "azurerm_lb_rule" "LB-rule" {
  resource_group_name            = azurerm_resource_group.RG.name
  loadbalancer_id                = azurerm_lb.LB.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "${var.resource_group}-lb-pip"
  backend_address_pool_id		 = azurerm_lb_backend_address_pool.BkEndAddPool.id
  probe_id						 = azurerm_lb_probe.Probe.id  
}

# Create NAT rule association with VM NIC 
#resource "azurerm_network_interface_nat_rule_association" "NAT-association" {
#  count					= var.num_of_vm
#  network_interface_id  = element(azurerm_network_interface.NIC.*.id,count.index)
#  ip_configuration_name = "${var.vm_name}-InternalIP-${count.index}"
  #nat_rule_id           = element(azurerm_lb_nat_rule.NAT-rule.*.id,count.index)
#}

# Create NIC association with LB Backend Address Pool
resource "azurerm_network_interface_backend_address_pool_association" "LB-backendpool-association" {
  count					  = var.num_of_vm
  network_interface_id    = element(azurerm_network_interface.NIC.*.id,count.index)
  ip_configuration_name   = "${var.vm_name}-InternalIP-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.BkEndAddPool.id
}

# Create Availability set
resource "azurerm_availability_set" "AvSet" {
  name                = "${var.resource_group}-AvS-01"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  platform_update_domain_count = 4
  platform_fault_domain_count = 3
  
  tags = {
    environment = var.environment
	department = var.department
  }
}

# Create a Virtual Machine
resource "azurerm_linux_virtual_machine" "VM" {
  name                            = "udacity-web-${count.index}"
  resource_group_name             = azurerm_resource_group.RG.name
  location                        = azurerm_resource_group.RG.location
  count							  = var.num_of_vm
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  availability_set_id 			  = azurerm_availability_set.AvSet.id
  network_interface_ids = [element(azurerm_network_interface.NIC.*.id,count.index)
  ]
#delete_os_disk_on_termination = true
#delete_data_disks_on_termination = true  
  
  os_disk {
	name				 = "osdisk-${count.index}"
    storage_account_type = var.storage_replication_type
    caching              = "ReadWrite"
  }
  source_image_id = var.image_resource_id
	
    tags = {
    environment = var.environment
	department = var.department
  }
}