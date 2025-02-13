# Define parameters
$ResourceGroupName = "powershell-grp"
$SourceVmName = "appvm1"
$DestinationVmName = "appvm2"
$DataDiskName = "app-disk1"

# Login to Azure account
Connect-AzAccount

# Detach the data disk from the source VM
$sourceVm = Get-AzVM -ResourceGroupName $ResourceGroupName -VMName $SourceVmName
$dataDisk = $sourceVm.StorageProfile.DataDisks | Where-Object { $_.Name -eq $DataDiskName }

if ($dataDisk -ne $null) {
    # Remove the data disk from the source VM
    $sourceVm = Remove-AzVMDataDisk -VM $sourceVm -Name $DataDiskName
    Update-AzVM -ResourceGroupName $ResourceGroupName -VM $sourceVm
    Write-Output "Data disk $DataDiskName detached from $SourceVmName."
} else {
    Write-Output "Data disk $DataDiskName not found on $SourceVmName."
    exit
}

# Attach the data disk to the destination VM
$destinationVm = Get-AzVM -ResourceGroupName $ResourceGroupName -VMName $DestinationVmName
$managedDisk = Get-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $DataDiskName

$destinationVm = Add-AzVMDataDisk -VM $destinationVm -Name $DataDiskName -ManagedDiskId $managedDisk.Id -Lun 1 -Caching ReadWrite
Update-AzVM -ResourceGroupName $ResourceGroupName -VM $destinationVm
Write-Output "Data disk $DataDiskName attached to $DestinationVmName."
