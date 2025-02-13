# Define parameters
$resourceGroupName = "powershell-grp"
$location = "NorthEurope"
$vmName = "appvm"
$adminUsername = "appvmuser"
$adminPassword = ConvertTo-SecureString "P@ssw0rd1234!" -AsPlainText -Force
$vmSize = "Standard_DS1_v2"

# Login to Azure account
Connect-AzAccount

# Create a Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create a Virtual Network and Subnet
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name "MyVNet" -AddressPrefix "10.0.0.0/16"
$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name "MySubnet" -AddressPrefix "10.0.0.0/24" -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork

# Create a Public IP Address
$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name "MyPublicIP" -AllocationMethod Dynamic

# Create a Network Security Group
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name "MyNSG"

# Create a Virtual Network Interface
$nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name "MyNIC" -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $publicIp.Id -NetworkSecurityGroupId $nsg.Id

# Create the VM Configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize |
   Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential (New-Object System.Management.Automation.PSCredential ($adminUsername, $adminPassword)) |
   Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest" |
   Add-AzVMNetworkInterface -Id $nic.Id

# Deploy the VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig
