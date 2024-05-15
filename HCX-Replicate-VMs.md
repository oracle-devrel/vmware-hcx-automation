[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_vmware-hcx-automation)](https://sonarcloud.io/dashboard?id=oracle-devrel_vmware-hcx-automation)

## Script 4: Protect VMs from On-prem to OCVS 
This script will Replicate Virtual machines from the Source vCenter to the Target vCenter.

## Procedure to run the script:
1.	Data Preparation:
Download the Data.xlsx file and Fill in the “ReplicateVMTemplate” sheet with the necessary details. Refer to the provided instructions within the same sheet.

3.	Script Execution:
Download the HCX-Replicate-VMs.ps1 script.
On a Windows server, open Windows PowerShell.
Run the HCX-Replicate-VMs.ps1script.
Choose the Data.xlsx Excel file when prompted.
Follow the onscreen instructions.
## End Result: Once the script finishes successfully, the VM replication begins to Cloud OCVS. You can then monitor the synchronization process using the HCX plugin.
