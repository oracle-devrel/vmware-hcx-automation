# vmware-hcx-automation

[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_vmware-hcx-automation)](https://sonarcloud.io/dashboard?id=oracle-devrel_vmware-hcx-automation)

## Objective:

VMware HCX automation, built with VMware PowerCLi Module on PowerShell, extracts data from Excel to execute tasks like HCX Connector setup, service mesh creation, network extension, VM migration, and VM replication. The Excel sheet serves as the VMware HCX infrastructure design document. 
This automation optimizes efficiency, delivering seamless migrations and substantial time savings for users. 
Ultimately, it facilitates a smooth transition to Oracle Cloud VMware Solution (OCVS), enhancing the overall migration journey and customer experience.

### Why VMware-HCX-Automation:

Using the regular console for VMware HCX migration or replication can be quite cumbersome. It involves a lot of clicking and takes a long time to set up HCX and perform migration or replication of Virtual Machines.

Additionally, manually doing this through the console is tedious and prone to errors.

With this automation in place, performing single-click Deployment, Migration, and Replication for a large number of VMs becomes feasible. The process is streamlined, enhancing efficiency while requiring minimal manual effort.


## How to get started?
**Download script** from the below table and check the **Procedure to run the script** for each script.

## Scripts in this Toolkit:

Script | What it does? | Download Script | Procedure to run the script
--- | --- | --- | ---
Script 1: HCX OVA Deploy & Configure | Deploy and Configure (vCenter Registration, Site Pairing, Service Mesh Creation) HCX Connector OVA on On-Premises vCenter | [HCX-Config.PS1](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/HCX-Config.ps1) | [HCX-Config.md](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/HCX-Config.md) 
Script 2: Extend On-prem Networks | Extend Distributed Switch Port Groups from the source vCenter to the destination NSX-T  | [ExtendNetworks.ps1](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/ExtendNetworks.ps1) | [ExtendNetworks.md](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/ExtendNetworks.md) 
Script 3: vMotion/Bulk/Cold Migration of VMs | This script facilitates the migration of virtual machines (Bulk Migration, Cross-cloud vMotion, Cold Migration) from the source vCenter to the OCVS vCenter | [HCX-Migrate-VMs.ps1](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/HCX-Migrate-VMs.ps1) | [HCX-Migrate-VMs.md](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/HCX-Migrate-VMs.md)
Script 4: Protect VMs from On-prem to OCVS | This script will Replicate Virtual machines from the Source vCenter to the Target vCenter | [HCX-Replicate-VMs.ps1](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/HCX-Replicate-VMs.ps1) | [HCX-Replicate-VMs.md](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/HCX-Replicate-VMs.md) 

## Each Script's Task:
<img src="https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/Services.png" alt="drawing" width="1000"/>


## Who can use these scripts??

Customers or Independent Software Vendors (ISVs) aiming to migrate or replicate a large number of virtual machines from an on-premises vCenter to the Oracle Cloud VMware Solution (OCVS).


## Advantages of VMware HCX Automation:

1.	Saves time :hourglass_flowing_sand:
2.	Minimizes manual labour :running:
3.	Accelerates migrations ⚡
4.	Ensures seamless transition to OCVS




## Contributing
This project is open source.  Please submit your contributions by forking this repository and submitting a pull request!  Oracle appreciates any contributions that are made by the open-source community.

## License
Copyright (c) 2022 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](LICENSE) for more details.

ORACLE AND ITS AFFILIATES DO NOT PROVIDE ANY WARRANTY WHATSOEVER, EXPRESS OR IMPLIED, FOR ANY SOFTWARE, MATERIAL OR CONTENT OF ANY KIND CONTAINED OR PRODUCED WITHIN THIS REPOSITORY, AND IN PARTICULAR SPECIFICALLY DISCLAIM ANY AND ALL IMPLIED WARRANTIES OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR PURPOSE.  FURTHERMORE, ORACLE AND ITS AFFILIATES DO NOT REPRESENT THAT ANY CUSTOMARY SECURITY REVIEW HAS BEEN PERFORMED WITH RESPECT TO ANY SOFTWARE, MATERIAL OR CONTENT CONTAINED OR PRODUCED WITHIN THIS REPOSITORY. IN ADDITION, AND WITHOUT LIMITING THE FOREGOING, THIRD PARTIES MAY HAVE POSTED SOFTWARE, MATERIAL OR CONTENT TO THIS REPOSITORY WITHOUT ANY REVIEW. USE AT YOUR OWN RISK. 
