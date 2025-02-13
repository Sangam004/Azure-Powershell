# Define parameters
$resourceGroupName = "powershell-grp"
$location = "NorthEurope"
$adminUsername = "appvmuser"
$adminPassword = ConvertTo-SecureString "P@ssw0rd1234!" -AsPlainText -Force
$vmSize = "Standard_DS1_v2"
$numberOfVMs = 3  # Specify the number of VMs to deploy

# Login to Azure account
Connect-AzAccount

# Create a Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create a Virtual Network and Subnet
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name "MyVNet" -AddressPrefix "10.0.0.0/16"
$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name "MySubnet" -AddressPrefix "10.0.0.0/24" -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork

for ($i = 1; $i -le $numberOfVMs; $i++) {
    # Create a unique VM name and other identifiers
    $vmName = "appvm$i"
    $publicIpName = "MyPublicIP$i"
    $nicName = "MyNIC$i"
    $nsgName = "MyNSG$i"

    # Create a Public IP Address
    $publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name $publicIpName -AllocationMethod Dynamic

    # Create a Network Security Group
    $nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name $nsgName

    # Create a Virtual Network Interface
    $nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name $nicName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $publicIp.Id -NetworkSecurityGroupId $nsg.Id

    # Create the VM Configuration
    $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize |
       Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential (New-Object System.Management.Automation.PSCredential ($adminUsername, $adminPassword)) |
       Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest" |
       Add-AzVMNetworkInterface -Id $nic.Id

    # Deploy the VM
    New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig
}
