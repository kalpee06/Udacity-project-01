variable "resource_group" {
  description = "Name of the resource group"
  default = "uda-proj-01"
}
variable "location" {
  description = "Azure region to launch resources"
  default = "East US"
}
variable "vm_size" {
	description = "Enter VM size needed"
	default = "Standard_D2s_v3"
}
variable "admin_username" {
	description = "Username for login"
	default = "spotcheck"
}
variable "admin_password" {
	description = "Password for username"
	default = "Changeme123!"
}
variable "storage_replication_type" {
	description = "Storage tier and type of replication"
	default = "Standard_LRS"
}
variable "image_resource_id" {
	description = "Resource information of image to be used"
	default = "/subscriptions/4c907634-af3f-48a3-9043-c3a06e5ab1a4/resourceGroups/packer-rg/providers/Microsoft.Compute/images/myPackerImage2"
}
variable "vnet_name" {
	description = "Name of the virtual network"
	default = "udacity-vnet"
}
variable "vnet_range" {
	description = "Vnet IP address range"
	default = ["10.0.0.0/22"]
}

variable "subnet_name" {
	description = "Name of the subnet"
	default = "uda-proj-01_subnet"
}
variable "subnet_range" {
	description = "Subnet IP address range"
	default = ["10.0.1.0/24"]
}
#variable "num_of_subnet" {
#	description = "How many subnets are needed"
#	default = 1
#}
variable "vm_name" {
	description = "Name of the virtual machine"
	#type = list(string)
	default = "udacity-web"
}
variable "num_of_nic" {
	description = "Number of Network Interface Cards to be provisioned"
	default = 1
}
variable "num_of_vm" {
	description = "How many virtual machines to create"
	type = number
	default = 2
}
variable "environment" {
	description = "Add value to environment tag key (production, stage, dev, test)"
}
variable "department" {
	description = "Add value to department tag key (IT, Finance, Research, HR)"
}	