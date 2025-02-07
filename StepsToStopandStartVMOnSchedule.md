Absolutely! Let's break this down and create a **scheduled automation script** to stop and deallocate your Azure Virtual Machines (VMs) at a specific time (e.g., overnight) and start them back up when needed.

### Steps for Automating VM Stop and Deallocation:

To automate the process, we'll use **Azure Automation**. Azure Automation allows you to create runbooks (scripts) that can run on a schedule.

Here’s a step-by-step guide to set this up:

---

### **Step 1: Create an Azure Automation Account**

1. **Login to Azure Portal**:  
   Go to [Azure Portal](https://portal.azure.com) and sign in to your account.

2. **Create an Automation Account**:  
   - In the left-hand menu, search for **Automation Accounts**.
   - Click on **+ Add** to create a new Automation Account.
   - Fill in the necessary fields, like **Subscription**, **Resource Group**, **Automation Account Name**, and **Region**.
   - Click **Create**.

---

### **Step 2: Create a Runbook**

A **Runbook** is where we’ll write the script to stop and deallocate your VMs.

1. **Navigate to your Automation Account**:  
   - Once your Automation Account is created, go to **Automation Accounts** and select your new account.

2. **Create a Runbook**:  
   - Under **Process Automation**, select **Runbooks**.
   - Click **+ Create a runbook**.
   - Name the Runbook (e.g., "Stop-Deallocate-VMs") and choose the **Runbook type** as **PowerShell**.

3. **Edit the Runbook**:  
   - After the runbook is created, click **Edit** to open the editor.
   - Copy and paste the following script into the editor. This script stops and deallocates VMs in a specified resource group.

---

### **Step 3: Write the PowerShell Script to Stop and Deallocate VMs**

Here's the script that will stop and deallocate all VMs in a specified **resource group**:

```powershell
# Define variables
$resourceGroupName = "yourResourceGroupName"   # Replace with your resource group name

# Authenticate to Azure (requires Azure Run As account)
$connectionAssetName = "AzureRunAsConnection"  # Uses Azure Run As account for authentication
$connection = Get-AutomationConnection -Name $connectionAssetName

# Login to Azure using the Run As Account
Connect-AzAccount -ServicePrincipal -TenantId $connection.TenantID -ApplicationId $connection.ApplicationID -CertificateThumbprint $connection.CertificateThumbprint

# Get all VMs in the resource group
$vms = Get-AzVM -ResourceGroupName $resourceGroupName

# Loop through each VM and stop & deallocate
foreach ($vm in $vms) {
    # Stop and deallocate the VM
    Write-Output "Stopping and Deallocating VM: $($vm.Name)"
    Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vm.Name -StayProvisioned $false -Force
}

Write-Output "All VMs have been stopped and deallocated."
```

**Explanation of the script:**
- `$resourceGroupName`: Specifies the resource group that contains the VMs to be deallocated.
- `Get-AutomationConnection`: Authenticates the runbook using the Azure Run As account.
- `Get-AzVM`: Retrieves all VMs in the specified resource group.
- `Stop-AzVM`: Stops and deallocates each VM in the resource group. The `-StayProvisioned $false` flag ensures the VM is deallocated.

---

### **Step 4: Test the Runbook**

1. **Save and Publish the Runbook**:  
   After pasting the script, click **Save** and then **Publish** the runbook.  
   (Publishing makes the runbook available for scheduling.)

2. **Test the Runbook**:  
   - Click **Start** to manually trigger the runbook.
   - Monitor the output and check if all VMs in the specified resource group are stopped and deallocated.

---

### **Step 5: Schedule the Runbook**

Now that the runbook is ready, let's set up a schedule to automatically stop and deallocate VMs at a specific time, such as at night.

1. **Create a Schedule**:  
   - Go to the **Schedules** tab in the Automation Account.
   - Click **+ Add a schedule**.
   - Set the schedule (for example, every day at 10:00 PM, or once a week).
   - After creating the schedule, note down the schedule name.

2. **Link the Schedule to the Runbook**:  
   - Go back to your **Runbook**, and in the **Runbook** page, click on **Link to schedule**.
   - Select the schedule you created in the previous step.
   - Click **OK** to link the schedule.

---

### **Step 6: Monitor and Verify**

1. **Monitor Runbook Jobs**:  
   - Once the runbook is scheduled, you can monitor its execution under the **Jobs** tab.
   - The automation will run as per your defined schedule, stopping and deallocating VMs automatically.

2. **Check VM State**:  
   - After the scheduled run, verify that the VMs are stopped and deallocated in your **Resource Group**.

---

### **Step 7: (Optional) Automate the Start Process**

If you also want to start your VMs back up in the morning or at another scheduled time, follow similar steps to create a runbook for starting the VMs.

### Example Script to Start VMs:

```powershell
# Define variables
$resourceGroupName = "yourResourceGroupName"   # Replace with your resource group name

# Authenticate to Azure (requires Azure Run As account)
$connectionAssetName = "AzureRunAsConnection"  # Uses Azure Run As account for authentication
$connection = Get-AutomationConnection -Name $connectionAssetName

# Login to Azure using the Run As Account
Connect-AzAccount -ServicePrincipal -TenantId $connection.TenantID -ApplicationId $connection.ApplicationID -CertificateThumbprint $connection.CertificateThumbprint

# Get all VMs in the resource group
$vms = Get-AzVM -ResourceGroupName $resourceGroupName

# Loop through each VM and start it
foreach ($vm in $vms) {
    # Start the VM
    Write-Output "Starting VM: $($vm.Name)"
    Start-AzVM -ResourceGroupName $resourceGroupName -Name $vm.Name
}

Write-Output "All VMs have been started."
```

Link this new start-runbook to a schedule if you want to automate the VM start process.

---

### **Conclusion:**

This process sets up a scheduled automation task to **stop and deallocate your VMs** when they are idle (e.g., at night) and saves you compute costs. You can further extend this with another script to **start the VMs** when you need them.
