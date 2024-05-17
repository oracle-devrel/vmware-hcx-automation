[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_vmware-hcx-automation)](https://sonarcloud.io/dashboard?id=oracle-devrel_vmware-hcx-automation)

## vMotion/Bulk/Cold Migration of VMs

This script facilitates the migration of virtual machines from the source vCenter to the OCVS vCenter. The customer can choose from three migration options: 

- Bulk Migration: Migrate multiple virtual machines simultaneously. 

- vMotion-Based Migration: Move powered-on virtual machines. 

- Cold Migration: Migrate virtual machines while they are powered off.


## Pre-Requisites:

1.	A Windows Jumpbox with PowerShell version 5 or higher.
2.	The execution policy in PowerShell should be set to **RemoteSigned**, run the following command (**if not executed before**)
      ```
      Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned.
      ```
3.	Run the following commands in PowerShell to Install the PowerCLi, Excel and SSH Module and Ignore the SSL (**if not executed before**)

      ```
      Install-Module VMware.PowerCLi -Scope CurrentUser -SkipPublisherCheck -AllowClobber -Force
      ```
      ```
      Install-Module -Name ImportExcel -Scope CurrentUser
      ```

4.    Connectivity Requirements:
      ```
      1. Verify that the Onprem HCX Manager Network can reach the Cloud Side HCX Manager on Port 443 (for site pairing).
      2. The Jump box should have access to the Onprem HCX Manager Network on port 443.
      ```



## Execution Steps:
1. Download the [Data.xlsx](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/Data.xlsx) file, Fill in the sheet named “**MigrateVMTemplate**” with the correct details. Refer to the instructions provided in the same sheet to complete each cell in the Excel file.

2. Download the PowerShell Script: [HCX-Migrate-VMs.ps1](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/HCX-Migrate-VMs.ps1)
On Windows, Execute it using PowerShell. Follow the onscreen instructions.

**End Result**: Once the script finishes successfully, the VM migration begins to Cloud OCVS. You can then monitor the synchronization process using the HCX plugin.
