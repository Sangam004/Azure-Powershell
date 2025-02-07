# Variables
$resourceGroupName = "yourResourceGroupName"      # Replace with your resource group name
$vmName = "yourVMName"                            # Replace with your VM name
$nicName = "newNic"                               # Name for the new NIC
$vnetName = "yourVnetName"                        # Replace with your VNet name
$subnetName = "yourSubnetName"                    # Replace with your subnet name
$location = "East US"                             # Replace with your location

# Authenticate with Azure (if not already authenticated)
Connect-AzAccount

# Get the virtual machine and stop it
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force

# Get the virtual network and subnet information
$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName
$subnet = $vnet | Get-AzVirtualNetworkSubnetConfig -Name $subnetName

# Create a new network interface for the VM
$nic = New-AzNetworkInterfaceConfig -Name $nicName -SubnetId $subnet.Id
$nicIpConfig = New-AzNetworkInterfaceIpConfig -Name "$nicName-IPConfig" -SubnetId $subnet.Id
$networkInterface = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name $nicName -IpConfiguration $nicIpConfig

# Get the VM's network interfaces
$nicList = Get-AzNetworkInterface -ResourceGroupName $resourceGroupName | Where-Object { $_.VirtualMachine -eq $null }

# Set the first NIC as the primary
$primaryNic = $nicList[0]
$primaryNic.Primary = $true

# Attach the new NIC to the VM
$vm | Set-AzVMNetworkInterface -Id $networkInterface.Id -Primary $false

# Update the VM
$vm | Update-AzVM

# Start the VM again
Start-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

Write-Host "Secondary network interface has been added and VM restarted."
