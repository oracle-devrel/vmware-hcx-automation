[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_vmware-hcx-automation)](https://sonarcloud.io/dashboard?id=oracle-devrel_vmware-hcx-automation)

## Script 1: HCX OVA Deploy & Configure
Deploys and Configures HCX Connector OVA on On-Premises vCenter

## Pre-Requisites:

1.	A Windows Jumpbox with PowerShell version 5 or higher.
2.	The execution policy in PowerShell should be set to **RemoteSigned**, run the following command:
      ```
      Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned.
      ```
3.	Run the following commands in PowerShell to Install the PowerCLi, Excel and SSH Module and Ignore the SSL:

      ```
      Install-Module VMware.PowerCLi -Scope CurrentUser -SkipPublisherCheck -AllowClobber -Force
      ```
      ```
      Install-Module -Name ImportExcel -Scope CurrentUser
      ```
      ```
      Install-Module -Name Posh-SSH -Scope CurrentUser -Confirm:$false
      ```
      ```
      Set-PowerCLiConfiguration -InvalidCertificateAction Ignore -Confirm:$false -ParticipateInCeip $false
      ```

4.    Connectivity Requirements:
      ```
      1. Ensure that HCX Onprem and HCX Cloud Server can connect to connect.hcx.vmware.com on 443 port for license activation.
      2. Verify that the Onprem HCX Manager Network can reach the Cloud Side HCX Manager on Port 443 (for site pairing).
      3. The Jump box should have access to the Onprem HCX Manager Network on port 22 and the Onprem vCenter IP or FQDN on Port 443.
      ```
      
## Procedure to run the script:
1. Download the HCX Connector OVA File from HCX Cloud UI: 

  ```Navigate to the HCX Cloud UI (https://hcxcloudmgr-ip-or-fqdn). Go to “Administration” > “System Updates.” Click “Request Download Link” to download the HCX Connector OVA file to Windows Jump box.```

2. Download the [Data.xlsx](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/Data.xlsx) file, Fill in the sheet named “**OVADeploy**” with the correct details. Refer to the instructions provided in the same sheet to complete each cell in the Excel file.

3. Download the [VMware.HCX.psm1](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/VMware.HCX.psm1) module to Jump box

4. Download the PowerShell Script: [HCX-Config.ps1](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/HCX-Config.ps1)
On Windows PowerShell and Run the HCX-Config.ps1 script. Follow the onscreen instructions.

## End result:

1.	**HCX Manager VM Deployment**: Upon successful execution of the script, the HCX Manager VM will be deployed in the on-premises vCenter. It will have a static IP address.
2.	**HCX License and Registration**: The script will apply the HCX license. It will also register with the on-premises vCenter and, if available, the on-premises NSX.
3.	**HCX Site-Pairing and Profiles**: The script will create HCX site-pairing. Additionally, it will set up compute profiles and network profiles. A service mesh will also be established.

## Next Script: Script 2: Extend On-prem Networks

