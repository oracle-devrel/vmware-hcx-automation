[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_vmware-hcx-automation)](https://sonarcloud.io/dashboard?id=oracle-devrel_vmware-hcx-automation)

## Script 2: Extend On-prem Networks. 
This script extends the Distributed Switch Port Groups from the source vCenter to the destination NSX-T using VMware HCX Network Extension feature.
## Note: Port groups with ephemeral bindings, untagged port groups, VMkernel port groups, and port groups from vSphere Standard switch cannot be extended.

## Procedure to run the script:
1.	Data Preparation:
o	Download the Data.xlsx file and Fill in the “NetworkExtension” sheet with the necessary details. Refer to the provided instructions within the same sheet.
2.	Script Execution:
o	Download the ExtendNetworks.ps1 script.
o	On a Windows server, open Windows PowerShell.
o	Run the ExtendNetworks.ps1 script.
o	Choose the Data.xlsx Excel file when prompted.
o	Follow the onscreen instructions.
## End Result: Upon successful completion of the script, your on-premises networks will be extended to the Cloud NSX-T, allowing you to utilize the extended networks.
## Next Script: Script 3: vMotion/Bulk/Cold Migration of VMs