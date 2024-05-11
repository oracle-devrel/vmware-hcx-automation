[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_vmware-hcx-automation)](https://sonarcloud.io/dashboard?id=oracle-devrel_vmware-hcx-automation)

## Script 1: HCX OVA Deploy & Configure
Deploy and Configure HCX Connector OVA on On-Premises vCenter

## Procedure to run the script:
1.	Download the HCX Connector OVA File:
o	Navigate to the HCX Cloud UI (https://hcxcloudmgr-ip-or-fqdn). Go to “Administration” > “System Updates.” Click “Request Download Link” to download the HCX Connector OVA file to Windows Jump box.
2.	Prepare the Data.xlsx File:
o	Download the Data.xlsx file, Fill in the sheet named “OVADeploy” with the correct details.
o	Refer to the instructions provided in the same sheet to complete each cell in the Excel file.
3.	Get the VMware.HCX.psm1 Module:
o	Download the VMware.HCX.psm1 module to Jump box
4.	Download the PowerShell Script:
o	Obtain the PowerShell script named “HCX-Config.ps1.”
5.	Execute the Script:
o	On a Windows server, open Windows PowerShell and Run the HCX-Config.ps1 script.
o	When prompted, choose the Data.xlsx Excel file.
o	Follow the onscreen instructions.

## End result:

1.	HCX Manager VM Deployment:
o	Upon successful execution of the script, the HCX Manager VM will be deployed in the on-premises vCenter. It will have a static IP address.
2.	HCX License and Registration:
o	The script will apply the HCX license.
o	It will also register with the on-premises vCenter and, if available, the on-premises NSX.
3.	HCX Site-Pairing and Profiles:
o	The script will create HCX site-pairing.
o	Additionally, it will set up compute profiles and network profiles.
o	A service mesh will also be established.

## Next Script: Script 2: Extend On-prem Networks

