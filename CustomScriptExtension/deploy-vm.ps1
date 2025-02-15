# Define parameters
$resourceGroupName = "powershell-grp"
$location = "NorthEurope"
$vmName = "appvm"
$adminUsername = "appvmuser"
$adminPassword = ConvertTo-SecureString "P@ssw0rd1234!" -AsPlainText -Force
$vmSize = "Standard_DS1_v2"
$storageAccountName = "iisconfigstorage"
$containerName = "scripts"
$scriptFileName = "IIS-Config.ps1"
$scriptLocalPath = "./$scriptFileName"
$scriptUri = "https://$storageAccountName.blob.core.windows.net/$containerName/$scriptFileName"

# Login to Azure account
Connect-AzAccount

# Create a Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create a Storage Account
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName "Standard_LRS"
$ctx = $storageAccount.Context
New-AzStorageContainer -Name $containerName -Context $ctx -Permission Blob
Set-AzStorageBlobContent -File $scriptLocalPath -Container $containerName -Context $ctx

# Create a Virtual Network and Subnet
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name "MyVNet" -AddressPrefix "10.0.0.0/16"
$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name "MySubnet" -AddressPrefix "10.0.0.0/24" -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork

# Create a Network Security Group and add rules for RDP (3389) and HTTP (80)
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name "MyNSG"
$nsg | Add-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Description "Allow RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange 3389
$nsg | Add-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "Allow HTTP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1001 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange 80
$nsg | Set-AzNetworkSecurityGroup

# Associate the NSG with the subnet
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "MySubnet" -AddressPrefix "10.0.0.0/24" -NetworkSecurityGroup $nsg
$vnet | Set-AzVirtualNetwork

# Create a Public IP Address
$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name "MyPublicIP" -AllocationMethod Dynamic

# Create a Virtual Network Interface
$nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name "MyNIC" -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $publicIp.Id -NetworkSecurityGroupId $nsg.Id

# Create the VM Configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize |
   Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential (New-Object System.Management.Automation.PSCredential ($adminUsername, $adminPassword)) |
   Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest" |
   Add-AzVMNetworkInterface -Id $nic.Id

# Deploy the VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

# Add the Custom Script Extension to the VM to install IIS
Set-AzVMCustomScriptExtension -ResourceGroupName $resourceGroupName -VMName $vmName -Name "CustomScriptExtension" -Location $location -FileUri $scriptUri -Run $scriptFileName
