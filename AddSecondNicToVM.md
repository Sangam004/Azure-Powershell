In Azure, the number of network interfaces (NICs) you can attach to a virtual machine (VM) depends on the size (SKU) of the VM.

Here’s a quick breakdown of NIC limits based on the VM size:

1. **Standard A-Series, D-Series, and F-Series VMs:**
   - These VMs support **up to 2 NICs** (one primary and one secondary).

2. **Standard DS-Series, Dv2-Series, and other similar SKUs (e.g., E-Series, N-Series):**
   - These VMs can support **up to 4 NICs**.

3. **High-performance VM sizes (e.g., M-Series, N-Series, and certain H-Series):**
   - These VMs can support **up to 8 NICs**.

4. **Azure HB and HC-Series VMs:**
   - These VMs support **up to 8 NICs**.

### Example of NICs per VM based on VM size:

- **Standard_D2_v3 (2 vCPUs, 8 GB RAM):** Supports **up to 2 NICs**.
- **Standard_E2_v3 (2 vCPUs, 16 GB RAM):** Supports **up to 4 NICs**.
- **Standard_M64ms (64 vCPUs, 1 TB RAM):** Supports **up to 8 NICs**.

The actual number of NICs supported depends on the **VM size** and the **Azure region** you're deploying in. It's always a good idea to check the official [Azure documentation on VM sizes and capabilities](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes) for the most up-to-date information.

Let me know if you need additional info!
