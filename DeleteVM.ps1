# Login to Azure account
Connect-AzAccount

# Set the subscription (you can choose it dynamically or set it to a specific one)
$subscription = Get-AzSubscription | Out-GridView -Title "Select Subscription" -PassThru
Set-AzContext -SubscriptionId $subscription.Id

# List all virtual machines in the subscription
$vmList = Get-AzVM

# Prompt user to select the VM to delete
$vm = $vmList | Out-GridView -Title "Select VM to Delete" -PassThru

# Get the Resource Group and VM details
$resourceGroupName = $vm.ResourceGroupName
$vmName = $vm.Name

# Get associated resources
$nic = Get-AzNetworkInterface -ResourceGroupName $resourceGroupName | Where-Object { $_.VirtualMachine.Id -eq $vm.Id }
$osDisk = $vm.StorageProfile.OsDisk.ManagedDisk
$dataDisks = $vm.StorageProfile.DataDisks | ForEach-Object { $_.ManagedDisk }
$publicIp = Get-AzPublicIpAddress -ResourceGroupName $resourceGroupName | Where-Object { $_.IpConfiguration.Id -eq $nic.IpConfigurations[0].Id }

# Confirm deletion
$confirmation = Read-Host "Are you sure you want to delete the VM '$vmName' and all its resources (OS Disk, Data Disks, Public IP, NIC)? (y/n)"
if ($confirmation -eq 'y') {
    Write-Host "Deleting VM '$vmName' and associated resources..."

    # Delete the Public IP Address (if exists)
    if ($publicIp) {
        Write-Host "Deleting Public IP Address: $($publicIp.Name)"
        Remove-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Name $publicIp.Name -Force
    }

    # Delete Network Interface (NIC)
    Write-Host "Deleting Network Interface: $($nic.Name)"
    Remove-AzNetworkInterface -ResourceGroupName $resourceGroupName -Name $nic.Name -Force

    # Delete Data Disks (if any)
    foreach ($dataDisk in $dataDisks) {
        Write-Host "Deleting Data Disk: $($dataDisk.Name)"
        Remove-AzDisk -ResourceGroupName $resourceGroupName -DiskName $dataDisk.Name -Force
    }

    # Delete OS Disk
    Write-Host "Deleting OS Disk: $($osDisk.Name)"
    Remove-AzDisk -ResourceGroupName $resourceGroupName -DiskName $osDisk.Name -Force

    # Delete the Virtual Machine
    Write-Host "Deleting Virtual Machine: $vmName"
    Remove-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force

    Write-Host "VM and associated resources have been deleted successfully."
} else {
    Write-Host "VM deletion cancelled."
}
