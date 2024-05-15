# vmware-hcx-automation

[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_vmware-hcx-automation)](https://sonarcloud.io/dashboard?id=oracle-devrel_vmware-hcx-automation)


## Objective:

VMware HCX automation, built with VMware PowerCLi Module on PowerShell, extracts data from Excel to execute tasks like HCX Connector setup, service mesh creation, network extension, VM migration, and VM replication. The Excel sheet serves as the VMware HCX infrastructure design document. This automation optimize efficiency, delivering seamless migrations and substantial time savings for users. Ultimately, it facilitates a smooth transition to OCVS, enhancing the overall migration journey and customer experience.


## Toolkit Supported Services:

1.	Script 1: HCX OVA Deploy & Configure
2.	Script 2: Extend On-prem Networks.
3.	Script 3: vMotion/Bulk/Cold Migration of VMs
4.	Script 4: Protect VMs from On-prem to OCVS






### Why VMware-HCX-Automation:

Using the regular console for VMware HCX migration or replication can be quite cumbersome. It involves a lot of clicking and takes a long time to set up migration or replication for just one virtual machine (VM).

Additionally, manually doing this through the console is both tedious and prone to errors.

With this automation in place, performing single-click Deployment, Migration, and Replication for a large number of VMs becomes feasible. The process is streamlined, enhancing efficiency while requiring minimal manual effort.


## How this toolkit works?
To run these scripts, follow these steps:
1.  Utilize PowerShell: Utilize PowerShell, a tool available on the computer.
2.  Input Data: Download and open the Data.xlsx file, then update the specific Excel sheet by entering the information relevant to the task at hand.
3.	Each script’s execution procedure is documented individually within this repository.
4.	Run the Script: After entering the data, run a specific script. The script will use the information from the Excel sheet as input.



## Who can use the toolkit??

Customers or Independent Software Vendors (ISVs) aiming to migrate or replicate a large number of virtual machines from an on-premises vCenter to the Oracle Cloud VMware Solution (OCVS).


## Pre-Requisites:

1.	A Windows Jump box (Preferably in the On-Prem Network) is required to execute the scripts, and it must be able to access the Onprem HCX Manager Network. Ports 22 and 443 should be open.
2.	Ensure that the PowerShell version on the Jump box is 5 or higher.
3.	The execution policy in PowerShell should be set: Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned.
4.	Install the PowerCLi module in PowerShell: Install-Module VMware.PowerCLi -Scope CurrentUser -SkipPublisherCheck -AllowClobber -Force.
5.	After installing VMWare PowerCLi, run this command: Set-PowerCLiConfiguration -InvalidCertificateAction Ignore -Confirm:$false -ParticipateInCeip $false.
6.	Install the Excel module in PowerShell: Install-Module -Name ImportExcel -Scope CurrentUser.
7.	Install the SSH Module: Install-Module -Name Posh-SSH -Scope CurrentUser -Confirm:$false.
8.	Ensure that HCX Onprem and HCX Cloud Server can connect to connect.hcx.vmware.com on 443 port for license activation.
9.	Verify that the Onprem HCX Manager Network can reach the Cloud Side HCX Manager on Port 443 (for site pairing).
10.	The Jump box should have access to the Onprem HCX Manager Network on port 22 and the Onprem vCenter IP or FQDN on Port 443.


## Advantages of VMware HCX Automation:

1.	Saves time
2.	Minimizes manual labour
3.	Accelerates migrations
4.	Ensures seamless transition to OCVS



## Where to get started?

Click the link: "https://github.com/oracle-devrel/vmware-hcx-automation" to download the Data Excel file, Scripts and procedure to run  each script.



## Contributing
This project is open source.  Please submit your contributions by forking this repository and submitting a pull request!  Oracle appreciates any contributions that are made by the open-source community.

## License
Copyright (c) 2022 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](LICENSE) for more details.

ORACLE AND ITS AFFILIATES DO NOT PROVIDE ANY WARRANTY WHATSOEVER, EXPRESS OR IMPLIED, FOR ANY SOFTWARE, MATERIAL OR CONTENT OF ANY KIND CONTAINED OR PRODUCED WITHIN THIS REPOSITORY, AND IN PARTICULAR SPECIFICALLY DISCLAIM ANY AND ALL IMPLIED WARRANTIES OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR PURPOSE.  FURTHERMORE, ORACLE AND ITS AFFILIATES DO NOT REPRESENT THAT ANY CUSTOMARY SECURITY REVIEW HAS BEEN PERFORMED WITH RESPECT TO ANY SOFTWARE, MATERIAL OR CONTENT CONTAINED OR PRODUCED WITHIN THIS REPOSITORY. IN ADDITION, AND WITHOUT LIMITING THE FOREGOING, THIRD PARTIES MAY HAVE POSTED SOFTWARE, MATERIAL OR CONTENT TO THIS REPOSITORY WITHOUT ANY REVIEW. USE AT YOUR OWN RISK. 
