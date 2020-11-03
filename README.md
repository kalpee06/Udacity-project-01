# Udacity-project-01
*********************
Deploying a Web server in Azure using Terraform and Packer.

Code requires all resources to be tagged and will ask for the tag values for tag keys Department and Environment.

Create a server image by using Packer.Sample code can be found by following the link.
[C1 - Azure Infrastructure Operations/project/starter_files/server.json]

Terraform code will help create below resources and make the required associations for connecting to the server via SSH.
- Resource Group - for all the resources to be deployed under the same resource group.
- Virtual network and Subnet - deploy the server in your company's preferred private address range.
- Create a Network Security group which will Allow and/or Deny traffic to the webserver.
- Create a Load Balancer with a FrontEnd Public IP and Backend Address Pool associated to the Load Balancer.
- Create a Virtual Machine Availability set - group with two or more virtual machines in the same Data Center ensuring availability of atleast one VM.
- Create Virtual Machines from previously created/existing images deployed via Packer.
- Create a variable file to help keep our code reusable by only changing the input parameters.

Getting Started - 
******************
Please refer to below files and clone repository as needed.
- packerproj.json to view Packer file.
- variables.json to provide input variables.
- main.tf to view the infrastructure code.
- vars.tf to view variables used.

Dependencies to note before starting the project - Please download and follow installation instructions mentioned on respective links.
Create an Azure Account - https://azure.microsoft.com/en-us/free/
Install the Azure command line interface - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
Install Packer - https://learn.hashicorp.com/tutorials/packer/getting-started-install
Install Terraform - depending on your OS - https://www.terraform.io/downloads.html

Some of the installation needs you to modify/add the PATH on your machine.

Terraform code files are #commented denoting the resource to be created by that section.

main.tf - 

  example - 
# Create a Resource group and add tags
resource "azurerm_resource_group" "RG" {
  name     = var.resource_group
  location = var.location
  tags = {
    environment = var.environment
	department = var.department
  }
}

vars.tf -

  example - 
variable "resource_group" {
  description = "Name of the resource group"
  default = "uda-proj-01"
}

Output

Running this code will create all necessary components for a Web server environment behind a Load Balancer.
Environment is also scalable and easy to deploy by changing the "num_of_vm" variable from the vars.tf file.



