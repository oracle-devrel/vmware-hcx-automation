[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_vmware-hcx-automation)](https://sonarcloud.io/dashboard?id=oracle-devrel_vmware-hcx-automation)

## Script 3: vMotion/Bulk/Cold Migration of VMs
## This script facilitates the migration of virtual machines from the source vCenter to the OCVS vCenter. The customer can choose from three migration options: 
1. Bulk Migration: Migrate multiple virtual machines simultaneously. 
2. vMotion-Based Migration: Move powered-on virtual machines. 
3. Cold Migration: Migrate virtual machines while they are powered off.


## Procedure to run the script:
1.	Data Preparation:
o	Download the Data.xlsx file and Fill in the “MigrateVMTemplate” sheet with the necessary details. Refer to the provided instructions within the same sheet.
2.	Script Execution:
o	Download the HCX-Migrate-VMs.ps1script script.
o	On a Windows server, open Windows PowerShell.
o	Run the HCX-Migrate-VMs.ps1script.
o	Choose the Data.xlsx Excel file when prompted.
o	Follow the onscreen instructions.
## End Result: Once the script finishes successfully, the VM migration begins to Cloud OCVS. You can then monitor the synchronization process using the HCX plugin.
## Next Script: Script 4: Protect VMs from On-prem to OCVS 
