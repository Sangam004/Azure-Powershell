# Variables
$resourceGroupName = "yourResourceGroupName"    # Replace with your resource group name
$vmName = "yourVMName"                          # Replace with your VM name
$storageAccountName = "yourStorageAccount"      # Replace with your storage account name
$location = "East US"                           # Replace with your preferred Azure location

# Authenticate to Azure
Connect-AzAccount

# Get the Virtual Machine
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

# Check if the Storage Account exists
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
if ($storageAccount -eq $null) {
    Write-Host "Storage account does not exist. Creating a new storage account..."

    # Create a new Storage Account (if it doesn't exist)
    $storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Location $location -Name $storageAccountName -SkuName Standard_LRS -Kind StorageV2
}

# Enable Boot Diagnostics
$bootDiagnostics = New-Object -TypeName Microsoft.Azure.Management.Compute.Models.BootDiagnostics
$bootDiagnostics.Enabled = $true
$bootDiagnostics.StorageUri = "https://$($storageAccountName).blob.core.windows.net/"

# Apply Boot Diagnostics to the VM
$vm | Set-AzVM -BootDiagnostics $bootDiagnostics

Write-Host "Boot Diagnostics has been enabled for VM '$vmName' using Storage Account '$storageAccountName'."
