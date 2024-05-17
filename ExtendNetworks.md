[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_vmware-hcx-automation)](https://sonarcloud.io/dashboard?id=oracle-devrel_vmware-hcx-automation)

## Extend On-prem Networks. 
This script extends the Distributed Switch Port Groups from the source vCenter to the destination NSX-T using the VMware HCX Network Extension feature.

>Note: Port groups with ephemeral bindings, untagged port groups, VMkernel port groups, and port groups from the vSphere Standard switch cannot be extended.

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
      ```
      Set-PowerCLiConfiguration -InvalidCertificateAction Ignore -Confirm:$false -ParticipateInCeip $false
      ```

4.    Connectivity Requirements:
      ```
      1. Verify that the Onprem HCX Manager Network can reach the Cloud Side HCX Manager on Port 443 (for site pairing).
      2. The Jump box should have access to the Onprem HCX Manager Network on port 443.
      ```

## Execution Steps:
1. Download the [Data.xlsx](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/Data.xlsx) file, Fill in the sheet named “**NetworkExtension**” with the correct details. Refer to the instructions provided in the same sheet to complete each cell in the Excel file.

2. Download the PowerShell Script: [ExtendNetworks.ps1](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/ExtendNetworks.ps1)
On Windows PowerShell. Run the ExtendNetworks.ps1 script. Follow the onscreen instructions.


**End Result**: Upon successful completion of the script, on-premises networks will be extended to the Cloud NSX-T, enabling the utilization of the extended networks.
