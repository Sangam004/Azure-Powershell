# Variables
$resourceGroupName = "yourResourceGroupName"  # Replace with your resource group name
$vmName = "yourVMName"                        # Replace with your VM name
$nsgName = "NewNetworkSecurityGroup"          # Name for the new NSG
$location = "East US"                         # Location for the NSG

# Authenticate to Azure
Connect-AzAccount

# Get the Virtual Machine
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

# Get the Network Interfaces attached to the VM
$nicList = Get-AzNetworkInterface | Where-Object { $_.VirtualMachine.Id -eq $vm.Id }

# Create a new Network Security Group (NSG)
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name $nsgName

# Optionally, you can create rules for your NSG if needed, for example:
# Create a rule to allow SSH (port 22)
$nsgRule = New-AzNetworkSecurityRuleConfig -Name "AllowSSH" -Protocol "Tcp" -Direction "Inbound" -Priority 100 -Access "Allow" -PortRange "22" -SourceAddressPrefix "Internet" -DestinationAddressPrefix "*" -DestinationPortRange "22"

# Add the rule to the NSG
$nsg | Set-AzNetworkSecurityGroup -SecurityRules $nsgRule

# Attach the NSG to the first network interface (if there are multiple, adjust as needed)
$nic = $nicList[0]  # If there's more than one NIC, adjust the index or logic to select the correct one
$nic | Set-AzNetworkInterface -NetworkSecurityGroupId $nsg.Id

Write-Host "NSG '$nsgName' has been successfully created and attached to the network interface of VM '$vmName'."
