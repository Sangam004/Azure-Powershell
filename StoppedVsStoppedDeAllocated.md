In Azure, there are two key states for Virtual Machines (VMs) that can impact costs:

### 1. **Stopped (VM State)**
   - **What it means:**  
     When a VM is in the **Stopped** state, it is no longer running, but the underlying resources (such as the virtual machine's OS disk and data disks) are still allocated.
   
   - **Key Points:**
     - The VM is **not running**, and it will not incur compute charges.
     - However, **storage charges** for the VM's OS disk, data disks, and the public IP address (if assigned) **will still apply**.
     - The VM cannot be restarted until you manually start it, but the infrastructure resources are still "reserved" for it, meaning you're paying for the storage and other associated resources.

   - **Use Case:**  
     It's used when you need to stop the VM but don't need to reduce the storage costs, or if you plan to restart it soon.

### 2. **Stopped (Deallocated)**
   - **What it means:**  
     When a VM is **Stopped (Deallocated)**, it is **completely shut down** and all associated resources (such as the compute resources) are released back to Azure. The VM is no longer allocated any compute resources, and it is not consuming CPU or RAM.
   
   - **Key Points:**
     - The **VM is deallocated**, which means you **stop being charged for compute resources** (the virtual machine itself).
     - **Storage charges** for the VM's OS and data disks **still apply**.
     - The **public IP address** (if static) will remain allocated and you will continue to incur costs for it.
     - The VM is **free to be reallocated** at any time, but starting the VM will take a little longer because the infrastructure has to be re-provisioned.

   - **Use Case:**  
     This state is ideal when you want to reduce both compute and storage costs when the VM is idle for a longer period (such as overnight or during weekends).

---

### **Which is best for reducing costs?**

To reduce costs when your Azure VMs are idle, **Stopped (Deallocated)** is the best option. Here’s why:

- **Compute Costs:**  
  When a VM is in the **Stopped (Deallocated)** state, you are **not billed for compute resources** (CPU, memory, etc.). You will still incur storage charges, but this can be a significant saving compared to the **Stopped** state, where compute resources are still allocated and billed.

- **Automating this:**  
  If you want to automate this for the night or during idle times, you can use Azure automation to stop and deallocate your VMs on a schedule.

### **How to stop and deallocate a VM:**
You can stop and deallocate a VM using Azure PowerShell:

```powershell
Stop-AzVM -ResourceGroupName "YourResourceGroupName" -Name "YourVMName" -StayProvisioned $false
```

The `-StayProvisioned $false` flag ensures that the VM is deallocated, not just stopped.

### **Conclusion:**
To reduce costs, especially for idle VMs (like overnight), **Stopping and Deallocating** is the best approach. Just be aware that deallocated VMs might take a little longer to start, as the resources will need to be re-provisioned.
