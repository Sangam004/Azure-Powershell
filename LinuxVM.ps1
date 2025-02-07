# Variables
$ResourceGroupName = "powershell-grp"
$Location = "North Europe"
$VirtualNetworkName = "app-network"
$VirtualNetworkAddressSpace = "10.0.0.0/16"
$SubnetName = "SubnetA"
$SubnetAddressSpace = "10.0.0.0/24"
$VMName = "MyLinuxVM"
$VMSize = "Standard_B1ms"  # Adjust as needed
$Image = "Canonical:UbuntuServer:20.04-LTS:latest"  # Ubuntu 20.04 LTS
$AdminUsername = "azureuser"  # Admin username for the VM
$SSHKeyPath = "~/.ssh/id_rsa.pub"  # Path to your public SSH key

# Authenticate to Azure
Connect-AzAccount

# Create the Resource Group
New-AzResourceGroup -Name $ResourceGroupName -Location $Location

# Create a Virtual Network and Subnet
$virtualNetwork = New-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Location $Location `
    -Name $VirtualNetworkName -AddressPrefix $VirtualNetworkAddressSpace

$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name $SubnetName `
    -AddressPrefix $SubnetAddressSpace -VirtualNetwork $virtualNetwork

# Create the Virtual Network
$virtualNetwork | Set-AzVirtualNetwork

# Create a Public IP address for the VM
$publicIp = New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Location $Location `
    -Name "${VMName}-publicIP" -AllocationMethod Dynamic

# Create a Network Security Group (NSG)
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $Location -Name "${VMName}-NSG"

# Create a Network Interface
$nic = New-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Location $Location `
    -Name "${VMName}-nic" -SubnetId $virtualNetwork.Subnets[0].Id `
    -PublicIpAddressId $publicIp.Id -NetworkSecurityGroupId $nsg.Id

# Get the SSH public key
$sshKey = Get-Content -Path $SSHKeyPath | Out-String

# Create the Virtual Machine
$vmConfig = New-AzVMConfig -VMSize $VMSize -AvailabilitySetId $null `
    -ImageName $Image -AdminUsername $AdminUsername -SSHKeyValue $sshKey

# Attach the network interface to the VM configuration
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

# Create and start the VM
New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $vmConfig -Name $VMName

Write-Host "Linux VM '$VMName' has been successfully created in '$Location'."
