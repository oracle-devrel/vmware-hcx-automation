

[![License: UPL](https://img.shields.io/badge/license-UPL-green)](https://img.shields.io/badge/license-UPL-green) [![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=oracle-devrel_vmware-hcx-automation)](https://sonarcloud.io/dashboard?id=oracle-devrel_vmware-hcx-automation)

# vmware-hcx-automation

- VMware HCX Automation facilitates effortless automation of your VMware HCX tasks. This solution enables efficient deployment and configuration of Onprem HCX Manager, along with migration/replication of virtual machines to Oracle Cloud VMware Solution (OCVS) by utilizing data extracted from Excel sheets.

- The automation streamlines processes, optimizing efficiency and ensuring seamless migrations, resulting in significant time savings for users. Ultimately, it facilitates a smooth transition to Oracle Cloud VMware Solution (OCVS), enhancing the overall migration journey and customer experience.

- This automation is built with VMware PowerCLi Module on PowerShell.


### Why VMware-HCX-Automation:

* Using the regular console for VMware HCX migration or replication can be quite cumbersome. It involves a lot of clicking and takes a long time to set up HCX and perform migration or replication of Virtual Machines.

* Additionally, manually doing this through the console is tedious and prone to errors.

* With this automation in place, performing single-click Deployment, Migration, and Replication for a large number of VMs becomes feasible. The process is streamlined, enhancing efficiency while requiring minimal manual effort.


## Who can use these scripts??

Customers or Independent Software Vendors (ISVs) aiming to migrate or replicate a large number of virtual machines from an on-premises vCenter to the Oracle Cloud VMware Solution (OCVS).


## How to get started?
```This toolkit includes four scripts: HCX OVA Deploy & Configure, Network Extension, VM Migration, and VM Replication. Each script is independent and can be executed based on specific requirements. Refer to the "Execution Instructions" section in the table below for guidance on running each script. More details about the scripts are provided in the table.```

## Automation scripts:

Script | What it does? | Download Script | Execution Instructions
--- | --- | --- | ---
HCX OVA Deploy & Configure | Deploys and configures HCX Connector OVA on On-Premises vCenter, including vCenter registration, site pairing, and service mesh creation.	 | [HCX-Config.PS1](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/HCX-Config.ps1) | [HCX-Config.md](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/HCX-Config.md) 
Extend On-prem Networks | Extend Distributed Switch Port Groups from the source vCenter to the destination NSX-T  | [ExtendNetworks.ps1](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/ExtendNetworks.ps1) | [ExtendNetworks.md](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/ExtendNetworks.md) 
vMotion/Bulk/Cold Migration of VMs | Migration of virtual machines (Bulk Migration, Cross-cloud vMotion, Cold Migration) from the source vCenter to the Target vCenter | [HCX-Migrate-VMs.ps1](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/HCX-Migrate-VMs.ps1) | [HCX-Migrate-VMs.md](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/HCX-Migrate-VMs.md)
Protect VMs from On-prem to OCVS | Replicates Virtual machines from the Source vCenter to the Target vCenter | [HCX-Replicate-VMs.ps1](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/HCX-Replicate-VMs.ps1) | [HCX-Replicate-VMs.md](https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/HCX-Replicate-VMs.md) 

## Script execution points:
<img src="https://github.com/oracle-devrel/vmware-hcx-automation/blob/develop/Services.png" alt="drawing" width="1000"/>



## Advantages of VMware HCX Automation:

✅ Saves time :hourglass_flowing_sand: \
✅ Minimizes manual labour :running: \
✅ Accelerates migrations ⚡ \
✅ Ensures seamless transition to OCVS \




## Contributing
This project is open source.  Please submit your contributions by forking this repository and submitting a pull request!  Oracle appreciates any contributions that are made by the open-source community.

## License
Copyright (c) 2022 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](LICENSE) for more details.

ORACLE AND ITS AFFILIATES DO NOT PROVIDE ANY WARRANTY WHATSOEVER, EXPRESS OR IMPLIED, FOR ANY SOFTWARE, MATERIAL OR CONTENT OF ANY KIND CONTAINED OR PRODUCED WITHIN THIS REPOSITORY, AND IN PARTICULAR SPECIFICALLY DISCLAIM ANY AND ALL IMPLIED WARRANTIES OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A PARTICULAR PURPOSE.  FURTHERMORE, ORACLE AND ITS AFFILIATES DO NOT REPRESENT THAT ANY CUSTOMARY SECURITY REVIEW HAS BEEN PERFORMED WITH RESPECT TO ANY SOFTWARE, MATERIAL OR CONTENT CONTAINED OR PRODUCED WITHIN THIS REPOSITORY. IN ADDITION, AND WITHOUT LIMITING THE FOREGOING, THIRD PARTIES MAY HAVE POSTED SOFTWARE, MATERIAL OR CONTENT TO THIS REPOSITORY WITHOUT ANY REVIEW. USE AT YOUR OWN RISK. 
