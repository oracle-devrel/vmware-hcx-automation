###############################################################################
<#
This script will help to deploy the HCX Connector OVA on the Onprem vCenter.

Prerequisites to check before running the script:
1.	Download the HCX Connector OVA file to the Windows Jumpbox from HCX Cloud UI (https://hcxcloudmgr-ip-or-fqdn --> Administration --> System Updates --> Click Request Download Link)
2.	Make sure the Excel Input file is properly filled with the right details.
3.	Install PowerCli module on PowerShell: Install-Module VMware.PowerCLI -Scope CurrentUser -SkipPublisherCheck -AllowClobber
4.	Run this command post installing VMWare PowerCli: Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -ParticipateInCeip $false
5.	Install Excel module on PowerShell: Install-Module -Name ImportExcel -Scope CurrentUser
6.	Install SSH Module: Install-Module -Name Posh-SSH -Scope CurrentUser -Confirm:$false
7.	Send the VMware.HCX.psm1 Module file to the customer.
8.	HCX Onprem and HCX Cloud Server should be able to reach connect.hcx.vmware.com for License activation.
9.	Make sure Onprem HCX Manager reaches the Cloud Side HCX Manager on Port 443. (For Site Pairing)
10. The Jumpbox should reach the Onprem HCX Manager on port 22 and Onprem vCenter Ip or FQDN on Port 443
#>
################################################################################
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -ParticipateInCeip $false

####################################Adding certificate exception to prevent API errors####################################
if ($PSVersionTable.PSEdition -eq "Desktop") {
    add-type @"
   using System.Net;
   using System.Security.Cryptography.X509Certificates;
   public class TrustAllCertsPolicy : ICertificatePolicy {
      public bool CheckValidationResult(
      ServicePoint srvPoint, X509Certificate certificate,
      WebRequest request, int certificateProblem) {
      return true;
   }
}
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    Write-host -ForegroundColor Green "`nAdding certificate exception to prevent API errors"

}
else {
    Write-host -ForegroundColor Green "`nCertificate Exception not required as the Core PS Edition is used"
}

Write-host -ForegroundColor Green "`n------------------------------------------------------`nInstalling HCX Connector VM on Onprem vCenter Started`n------------------------------------------------------" 

####################################Connecting to vCenter Onprem vCenter Server####################################
Write-Host -ForegroundColor Yellow "`nConnecting to Onprem vCenter Server"
$Server = Read-Host -Prompt 'Enter vCenter Server'
$Cre = Get-Credential
Write-Host "Connecting to vCenter:" $Server"..."
try {
    Connect-VIserver -server $Server -credential $Cre -ErrorAction Stop
}
catch {
    throw "Connection to vCenter Server failed!"
}
Write-Host -ForegroundColor Green "`nConnection to vCenter Server: "$Server" has been extablished successfully."

#################################### Browsing the required files ####################################
Write-host -ForegroundColor Yellow "`nChoose the excel file to feed the data to the script"
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
#$FileBrowser.filter = 'SpreadSheet (*.xlsx)|*.xlsx'
[void]$FileBrowser.ShowDialog()
$path = $FileBrowser.FileName 

Write-host -ForegroundColor Yellow "`nChoose the VMWARE.HCX Module to configure HCX Manager"
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
#$FileBrowser.filter = 'PSModule (*.psm1)|*.psm1'
[void]$FileBrowser.ShowDialog()
$modulepath = $FileBrowser.FileName


Write-host -ForegroundColor Yellow "`nChoose the OVA file to deploy HCX Connector"
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
#$FileBrowser.filter = 'OVA (*.ova)|*.ova'
[void]$FileBrowser.ShowDialog()
$ovffile = $FileBrowser.FileName 

#################################### Reading the Variables from Excel File ####################################
#Load OVF/OVA configuration into a variable
$Data = Import-Excel $path -WorksheetName OVAdeploy

for ($i = 0; $i -lt $Data.Count - 1; $i++) {
    # vSphere Cluster + VM Network configurations
    $OnPremvCenter = $Data[$i].OnPremvCenter
    $OnPremVCUsername = $Data[$i].OnPremVCUsername
    $SSODomain = $Data[$i].SSODomain
    $ComputeClusterName = $Data[$i].OnpremComputeCluster
    $HCXVMName = $Data[$i].HCXVMName
    $hcxManagementNetworkBackingName = $Data[$i].HcxConnectorNetwork
    $Hostname = $Data[$i].HcxConnectorHostname
    $HcxConnectorIP = $Data[$i].HcxConnectorIP
    $SubnetMask = $Data[$i].SubnetMask
    $DefaultGateway = $Data[$i].DefaultGateway
    $DNS = $Data[$i].DNS
    $DomainName = $Data[$i].DomainName
    $NTPServer = $Data[$i].NTPServer
    $OnpremDataStore = $Data[$i].OnpremDataStore
    $ActivationKey = $Data[$i].ActivationKey
    $HCXVAMIUsername = $Data[$i].HCXVAMIUsername
    $OnpremNSXServer = $Data[$i].OnpremNSXServer
    $OnpremNSXUsername = $Data[$i].OnpremNSXUsername
    $HCXCloudURL = $Data[$i].HCXCloudURL
    $HCXCloudUsername = $Data[$i].HCXCloudUsername
    $HCXServiceMeshName = $Data[$i].HCXServiceMeshName
    $HCXComputeProfileName = $Data[$i].HCXComputeProfileName
    $HCXVDSName = $Data[$i].HCXVDSName
    $OnpremDNSSuffix = $Data[$i].OnpremDNSSuffix
    $EnableSSH = $Data[$i].EnableSSH
    $vSphereSwitchType = $Data[$i].vSphereSwitchType
   

    #HCX Network Profile creation details
    $HCXMgmtNetworkProfileName = $Data[$i].HCXMgmtNetworkProfileName
    $HCXMgmtNetworkProfileNetwork = $Data[$i].HCXMgmtNetworkProfileNetwork
    $HCXMgmtNetworkProfileSubnetMask = $Data[$i].HCXMgmtNetworkProfileSubnetMask
    $HCXMgmtNetworkProfileGateway = $Data[$i].HCXMgmtNetworkProfileGateway
    $SMMgmtIPPOOL = $Data[$i].SMMgmtIPPOOL
    
    $HCXvMotionNetworkProfileName = $Data[$i].HCXvMotionNetworkProfileName
    $HCXvMotionNetworkProfileNetwork = $Data[$i].HCXvMotionNetworkProfileNetwork
    $HCXvMotionNetworkProfileSubnetMask = $Data[$i].HCXvMotionNPSubnetMask
    $HCXvMotionNetworkProfileGateway = $Data[$i].HCXvMotionNPGateway
    $SMvMotionIPPOOL = $Data[$i].SMvMotionIPPOOL

    $HCXReplicationNetworkProfileName = $Data[$i].HCXReplicationNetworkProfileName
    $HCXReplicationNetworkProfileNetwork = $Data[$i].HCXReplicationNetworkProfileNetwork
    $HCXReplicationNPSubnetMask = $Data[$i].HCXReplicationNPSubnetMask
    $HCXReplicationNPGateway = $Data[$i].HCXReplicationNPGateway
    $SMReplicationIPPOOL = $Data[$i].SMReplicationIPPOOL
    
    $HCXUplinkNetworkProfileName = $Data[$i].HCXUplinkNetworkProfileName
    $HCXUplinkNetworkProfileNetwork = $Data[$i].HCXUplinkNetworkProfileNetwork
    $HCXUplinkNPSubnetMask = $Data[$i].HCXUplinkNPSubnetMask
    $HCXUplinkNPGateway = $Data[$i].HCXUplinkNPGateway
    $SMUplinkIPPOOL = $Data[$i].SMUplinkIPPOOL

    $vMotionRequired = $Data[$i].vMotionRequired
}  

#################################### This block of script will collect the passwords required ####################################
while (1) {
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "`nEnter New Cli Password for HCX manager (Do Not Use: ()?$*+^[]\)"
    $CliPasswordTemp1 = Read-Host -Prompt "Enter New Cli Password for HCX manager (Do Not Use: ()?$*+^[]\)" -AsSecureString
    $CliPassword1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($CliPasswordTemp1))

    Write-Host -ForegroundColor Yellow -BackgroundColor Black "`nRe-enter New CliPassword for HCX manager (Do Not Use: ()?$*+^[]\)"
    $CliPasswordTemp2 = Read-Host -Prompt "Re-enter New CliPassword for HCX manager (Do Not Use: ()?$*+^[]\)" -AsSecureString
    $CliPassword2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($CliPasswordTemp2))

    if (($CliPassword1 -cmatch $CliPassword2) -and ($CliPassword1.Length -eq $CliPassword2.Length) -and ($CliPassword1.Length -gt 7)) {
        Write-Host -ForegroundColor Green "`nClipassowrds entered Match"
        break
    }
    else {
        Write-Host -ForegroundColor Red "CliPassword Entered doesn't match, re-enter the password"
    }
}

while (1) {
        
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "`nEnter New Root Password  for HCX manager (Do Not Use: ()?$*+^[]\)"
    $RootPasswordTemp1 = Read-Host -Prompt "Enter New Root Password  for HCX manager (Do Not Use: ()?$*+^[]\)" -AsSecureString
    $RootPassword1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($RootPasswordTemp1))

    Write-Host -ForegroundColor Yellow -BackgroundColor Black "`nRe-enter New Root Password  for HCX manager (Do Not Use: ()?$*+^[]\)"
    $RootPasswordTemp2 = Read-Host -Prompt "Re-enter New Root Password  for HCX manager (Do Not Use: ()?$*+^[]\)" -AsSecureString
    $RootPassword2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($RootPasswordTemp2))

    if (($RootPassword1 -cmatch $RootPassword2) -and ($RootPassword1.Length -eq $RootPassword2.Length) -and ($RootPassword1.Length -gt 7)) {
        Write-Host -ForegroundColor Green "`nRoot Passwords entered Match"
        break
    }
    else {
        Write-Host -ForegroundColor Red "Root Password Entered doesn't match, re-enter the password"
    }
}

$VIPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Cre.Password))

Write-Host -ForegroundColor Yellow -BackgroundColor Black "`nEnter Cloud vCenter Password, Please copy and paste..."
$CloudVCPasswordTemp = Read-Host -Prompt "Enter the Cloud vCenter Password, Please copy and paste..." -AsSecureString
$CloudVCPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($CloudVCPasswordTemp))

if ($OnpremNSXServer) {
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "`nEnter the Onprem NSX Manager Password, Please copy and paste..."
    $NSXPasswordTemp = Read-Host -Prompt "Please Enter Onprem NSX Password, Please copy and paste..." -AsSecureString
    $NSXPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($NSXPasswordTemp)) 
}

$HCXCreds = new-object -typename System.Management.Automation.PSCredential -argumentlist admin, $CliPasswordTemp1

#################################### OVF/OVA configuration parameters ####################################
$VMHost = Get-Cluster $ComputeClusterName | Get-VMHost | Sort MemoryGB | Select-Object -first 1
$Datastore = $VMHost | Get-datastore -Name $OnpremDataStore  # | Sort FreeSpaceGB -Descending | Select -first 1

if ($vSphereSwitchType -eq "DistributedSwitch" ) {
    $Network = Get-VDPortGroup -Name $hcxManagementNetworkBackingName
}
else {
    $Network = Get-VirtualPortGroup -Name $hcxManagementNetworkBackingName
}

# Load OVF/OVA configuration into a variable
$ovfconfig = Get-OvfConfiguration $ovffile

# vSphere Portgroup Network Mapping
$ovfconfig.NetworkMapping.VSMgmt.value = $Network[0]

# IP Address
$ovfConfig.common.mgr_ip_0.value = $HcxConnectorIP

# Netmask
$ovfConfig.common.mgr_prefix_ip_0.value = $SubnetMask

# Gateway
$ovfConfig.common.mgr_gateway_0.value = $DefaultGateway

# DNS Server
$ovfConfig.common.mgr_dns_list.value = $DNS

# DNS Domain
$ovfConfig.common.mgr_domain_search_list.value = $DomainName

# Hostname
$ovfconfig.Common.hostname.Value = $Hostname

# NTP
$ovfconfig.Common.mgr_ntp_list.Value = $NTPServer

# SSH
$ovfconfig.Common.mgr_isSSHEnabled.Value = ([System.Convert]::ToBoolean($EnableSSH))

# Password
$ovfconfig.Common.mgr_cli_passwd.Value = $CliPassword1
$ovfconfig.Common.mgr_root_passwd.Value = $RootPassword1

#################################### Deploy the OVF/OVA with the config parameters ####################################
Write-Host -ForegroundColor Green "`nDeploying HCX Manager OVA ..."
$vm = Import-VApp -Source $ovffile -OvfConfiguration $ovfconfig -Name $HCXVMName -VMHost $VMHost -Datastore $datastore -DiskStorageFormat thin

# Power On the HCX Manager VM after deployment
Write-Host -ForegroundColor Green "`nPowering on HCX Manager ..."
$vm | Start-VM -Confirm:$false | Out-Null

#################################### Waiting for HCX Manager to initialize ####################################

while (1) {
    try {
        if ($PSVersionTable.PSEdition -eq "Desktop") {
            $requests = Invoke-WebRequest -Uri "https://$($ovfConfig.common.mgr_ip_0.value):9443" -Method GET -TimeoutSec 5
        }
        else {
            $requests = Invoke-WebRequest -Uri "https://$($ovfConfig.common.mgr_ip_0.value):9443" -Method GET -SkipCertificateCheck -TimeoutSec 5
        }
        if ($requests.StatusCode -eq 200) {
            Write-Host -ForegroundColor Green "HCX Manager is now ready to be configured!"
            break
        }
    }
    catch {
        Write-Host -ForegroundColor Yellow "HCX Manager is not ready yet, waiting for services to start"
        sleep 30
    }
}

Write-host -ForegroundColor Yellow ("`nHCX Manager VM details updated to the excel file @ ")$path ("SheetName: HCXManagerVMDetails") 
Get-VM -Name $vm | Export-Excel $path -WorksheetName HCXManagerVMDetails

######################################################################################################
<#Configuring HCX manager: Here the Onprem HCX manager will be registered with the Onprem vCenter, 
    Onprem SSO, Onprem NSX if avaialble. HCX License will be applied and HCX Role mapping will be set#>
######################################################################################################
Write-Host -ForegroundColor Green "`n--------------------------`nConfiguring HCX manager`n--------------------------"
Write-Host -ForegroundColor Yellow "`nImporting VMware.HCX Module"
Import-Module $modulepath

#################################### Connecting to HCX Vami Page ####################################
Write-Host -ForegroundColor Yellow "`nConnecting to HCX Vami Page"
$global:hcxVAMIConnection = Connect-HcxVAMI -Server $HcxConnectorIP -Username $HCXVAMIUsername -Password $CliPassword1
$global:hcxVAMIConnection
sleep 3

#################################### Setting up HCX License ####################################
Write-Host -ForegroundColor Yellow "`nSetting up HCX License"
    
while (1) {
    try {
        $Command = "curl -k https://connect.hcx.vmware.com"
        $SSHSession = New-sshsession -ComputerName $HcxConnectorIP -Credential $HCXCreds -Force
        $sshOutput1 = Invoke-sshcommand -SSHSession $SSHSession -Command $Command

        if ($sshOutput1.ExitStatus -eq 0) {
            Write-Host "HCX Connector: " $HcxConnectorIP "connected successfully to https://connect.hcx.vmware.com"
            Set-HcxLicense -LicenseKey $ActivationKey
            sleep 3
            break
        }
    }
    catch {
        write-host "Connection failed, please make sure HCX Connector:" $HcxConnectorIP "Connects to Internet"
        Sleep 30
    }
}
   
#################################### Registering Onprem VC,SSO and NSX with Onprem HCX Manager ####################################

Write-Host -ForegroundColor Yellow "`nRegistering Onprem VC with Onprem HCX Manager"
Set-HcxVCConfig -VIServer $OnPremvCenter -VIUsername $OnPremVCUsername -VIPassword $VIPassword  -PSCServer $OnPremvCenter
sleep 5

if ($OnpremNSXServer) {
    Write-Host -ForegroundColor Yellow "`nAdding NSX Onprem Certificate to HCX ONprem Trusted Cert Store"
    $endpoint = "https://" + $HcxConnectorIP + ":9443/api/admin/certificates"
    $payloadtempnsx = "https://" + $OnpremNSXServer
    $payloadnsx = @{url = $payloadtempnsx }
    # Convert the payload to JSON format
    $jsonPayload = ConvertTo-Json($payloadnsx)
    # Make the API call using Invoke-RestMethod

    if ($PSVersionTable.PSEdition -eq "Desktop") {
        $nsxcertrequest = Invoke-RestMethod -Uri $endpoint -Method POST -Body $jsonPayload -Headers $global:hcxVAMIConnection.headers -ErrorAction Stop
    }
    else {
        $nsxcertrequest = Invoke-RestMethod -Uri $endpoint -Method POST -Body $jsonPayload -Headers $global:hcxVAMIConnection.headers -ErrorAction Stop -SkipCertificateCheck
    }
    # Output the response
    Write-Output $nsxcertrequest

    if ($nsxcertrequest.success) {
        Write-Host -ForegroundColor Green "NSX Certificate Imported Succesfully"
    }
    else {
        Write-host -ForegroundColor Red "Import NSX Certificate Failed, Import Cert Manually and run the code from where it stopped"
    } 
    Set-HcxNSXConfig -NSXServer $OnpremNSXServer -NSXUsername $OnpremNSXUsername -NSXPassword $NSXPassword
    sleep 5
    Write-Host -ForegroundColor Green "NSX Manager Registered"
}
else {
    Write-Host -ForegroundColor Yellow "`nNo NSX Manager found onprem"
}

Set-HcxLocation -City "Phoenix" -Country "United States of America"
Set-HcxRoleMapping -SystemAdminGroup @($SSODomain) -EnterpriseAdminGroup @($SSODomain)


#################################### Adding HCX cloud Certificate to HCX ONprem Trusted Cert Store ####################################
Write-Host -ForegroundColor Yellow "`nImporting the Cloud HCX Manager Certificate to OnPrem HCX Manager`n-----------------------------------------------------------------------"
Write-Host -ForegroundColor Yellow "`nAdding HCX cloud Certificate to HCX ONprem Trusted Cert Store"
$endpoint = "https://" + $HcxConnectorIP + ":9443/api/admin/certificates"
$payloadtemp = "https://" + $HCXCloudURL
$payload = @{url = $payloadtemp }
# Convert the payload to JSON format
$jsonPayload = ConvertTo-Json($payload)
# Make the API call using Invoke-RestMethod

if ($PSVersionTable.PSEdition -eq "Desktop") {
    $certrequest = Invoke-RestMethod -Uri $endpoint -Method POST -Body $jsonPayload -Headers $global:hcxVAMIConnection.headers -ErrorAction Stop
}
else {
    $certrequest = Invoke-RestMethod -Uri $endpoint -Method POST -Body $jsonPayload -Headers $global:hcxVAMIConnection.headers -ErrorAction Stop -SkipCertificateCheck
}
# Output the response
Write-Output $certrequest

if ($certrequest.success) {
    Write-Host -ForegroundColor Green "HCX Cloud Certificate Imported Succesfully"
}
else {
    Write-host -ForegroundColor Red "Import Certificate Failed, Import Cert Manually and run Site Pairing and Service Mesh creation"
    break
} 

Write-Host -ForegroundColor Yellow "`nRemoving Module VMware.HCX"
Remove-Module -Name VMware.HCX

#############################################################################
<#Creating SitePairing, Network Profiles, Compute Profile and Service Mesh#>
#############################################################################
Write-Host -ForegroundColor Green "`n-----------------------------------------------`nProfile and Service Mesh creation started....`n-----------------------------------------------"

#################################### Authenticating to HCX Manager ####################################
Write-Host -ForegroundColor Green "`nConnecting to Onprem HCX Manager..."
VMware.VimAutomation.Hcx\Connect-HCXServer -Server $HcxConnectorIP -Username $OnPremVCUsername -Password $VIPassword

#################################### Creating Site Pairing ####################################
Write-Host -ForegroundColor Green "`nCreating Site Pairing..."
New-HCXSitePairing -Url $HCXCloudURL -Username $HCXCloudUsername -Password $CloudVCPassword

#################################### Creating Network Profile ####################################
Write-Host -ForegroundColor Yellow "`nCreating Management Network Profile...`n-----------------------------"
$myMgmtNetworkBacking = Get-HCXNetworkBacking -Name $HCXMgmtNetworkProfileNetwork
New-HCXNetworkProfile -PrimaryDNS $DNS -DNSSuffix $OnpremDNSSuffix -Name $HCXMgmtNetworkProfileName -GatewayAddress $HCXMgmtNetworkProfileGateway -IPPool $SMMgmtIPPOOL -Network $myMgmtNetworkBacking -PrefixLength $HCXMgmtNetworkProfileSubnetMask
$managementNetworkProfile = Get-HCXNetworkProfile -Name $HCXMgmtNetworkProfileName
Write-Host -ForegroundColor Green "`nManagement Network Profile created Successfully..."

if ($HCXvMotionNetworkProfileNetwork) {
    Write-Host -ForegroundColor Green "`nCreating vMotion Network Profile...`n----------------------------------------"
    $myvMotionNetworkBacking = Get-HCXNetworkBacking -Name $HCXvMotionNetworkProfileNetwork
    New-HCXNetworkProfile -PrimaryDNS $DNS -DNSSuffix $OnpremDNSSuffix -Name $HCXvMotionNetworkProfileName -GatewayAddress $HCXvMotionNetworkProfileGateway -IPPool $SMvMotionIPPOOL -Network $myvMotionNetworkBacking -PrefixLength $HCXvMotionNetworkProfileSubnetMask
    Write-Host -ForegroundColor Green "`nvMotion Network Profile created Successfully..."
    $vmotionNetworkProfile = Get-HCXNetworkProfile -Name $HCXvMotionNetworkProfileName
}
else {
    $vmotionNetworkProfile = Get-HCXNetworkProfile -Name $HCXMgmtNetworkProfileName
}

if ($HCXReplicationNetworkProfileNetwork) {
    Write-Host -ForegroundColor Green "`nCreating Replication Network Profile...`n----------------------------------------"
    $myReplicationNetworkBacking = Get-HCXNetworkBacking -Name $HCXReplicationNetworkProfileNetwork
    New-HCXNetworkProfile -PrimaryDNS $DNS -DNSSuffix $OnpremDNSSuffix -Name $HCXReplicationNetworkProfileName -GatewayAddress $HCXReplicationNPGateway -IPPool $SMReplicationIPPOOL -Network $myReplicationNetworkBacking -PrefixLength $HCXReplicationNPSubnetMask
    Write-Host -ForegroundColor Green "`nReplication Network Profile created Successfully..."
    $ReplicationNetworkProfile = Get-HCXNetworkProfile -Name $HCXReplicationNetworkProfileName
}
else {
    $ReplicationNetworkProfile = Get-HCXNetworkProfile -Name $HCXMgmtNetworkProfileName
}

if ($HCXUplinkNetworkProfileNetwork) {
    Write-Host -ForegroundColor Green "`nCreating Uplink Network Profile...`n----------------------------------------"
    $myUplinkNetworkBacking = Get-HCXNetworkBacking -Name $HCXUplinkNetworkProfileNetwork
    New-HCXNetworkProfile -PrimaryDNS $DNS -DNSSuffix $OnpremDNSSuffix -Name $HCXUplinkNetworkProfileName -GatewayAddress $HCXUplinkNPGateway -IPPool $SMUplinkIPPOOL -Network $myUplinkNetworkBacking -PrefixLength $HCXUplinkNPSubnetMask
    Write-Host -ForegroundColor Green "`nvMotion Uplink Profile created Successfully..."
    $UplinkNetworkProfile = Get-HCXNetworkProfile -Name $HCXUplinkNetworkProfileName
}
else {
    $UplinkNetworkProfile = Get-HCXNetworkProfile -Name $HCXMgmtNetworkProfileName
}

#################################### Creating Compute Profile and Service Mesh ####################################

#Capturing few variables
$cluster = Get-HCXApplianceCompute -ClusterComputeResource -Name $ComputeClusterName
$datastore = Get-HCXApplianceDatastore -Compute $cluster -Name $OnpremDataStore
sleep 3
while (1) {
    try {
        $num = 10 + 20
        #$SSHSession = New-sshsession -ComputerName $HcxConnectorIP -Credential $HCXCreds -Force
        #$sshOutput1 = Invoke-sshcommand -SSHSession $SSHSession -Command $Command

        if ($num -eq 30) {
            Write-Host "`nGetting the Destination HCX details"
            $destination = Get-HCXSite -Destination #-Server $HcxConnectorIP
            $destination
            sleep 3
            break
        }
    }
    catch {
        write-host "`nUnable to get the HCX destination Details"
        Sleep 3
    }
}
sleep 3
$hcxRemoteComputeProfile = Get-HCXComputeProfile -Site $destination

if (($HCXVDSName) -and ($vMotionRequired -match "True")) {
    $dvs = Get-HCXInventoryDVS -Compute $cluster -Name $HCXVDSName
    New-HCXComputeProfile -ManagementNetworkProfile $managementNetworkProfile -vMotionNetworkProfile $vmotionNetworkProfile -vSphereReplicationNetworkProfile $ReplicationNetworkProfile -UplinkNetworkProfile $UplinkNetworkProfile -Name $HCXComputeProfileName -Service BulkMigration, DisasterRecovery, Interconnect, NetworkExtension, Vmotion, WANOptimization -Datastore $datastore -DeploymentResource $cluster -ServiceCluster $cluster -DistributedSwitch $dvs
    Write-Host -ForegroundColor Green "`nCompute Profile created Successfully..."

    Write-Host -ForegroundColor Green "`nCreating Service mesh...`n--------------------------"
    $hcxLocalComputeProfile = Get-HCXComputeProfile -Name $HCXComputeProfileName
    New-HCXServiceMesh -SourceComputeProfile $hcxLocalComputeProfile -Destination $destination -DestinationComputeProfile $hcxRemoteComputeProfile -Service BulkMigration, DisasterRecovery, Interconnect, NetworkExtension, Vmotion, WANOptimization -Name $HCXServiceMeshName -SourceUplinkNetworkProfile $UplinkNetworkProfile
}
elseif (($HCXVDSName) -and ($vMotionRequired -match "False")) {
    $dvs = Get-HCXInventoryDVS -Compute $cluster -Name $HCXVDSName
    New-HCXComputeProfile -ManagementNetworkProfile $managementNetworkProfile -vMotionNetworkProfile $vmotionNetworkProfile -vSphereReplicationNetworkProfile $ReplicationNetworkProfile -UplinkNetworkProfile $UplinkNetworkProfile -Name $HCXComputeProfileName -Service BulkMigration, DisasterRecovery, Interconnect, NetworkExtension, WANOptimization -Datastore $datastore -DeploymentResource $cluster -ServiceCluster $cluster -DistributedSwitch $dvs
    Write-Host -ForegroundColor Green "`nCompute Profile created Successfully..."

    Write-Host -ForegroundColor Green "`nCreating Service mesh...`n--------------------------"
    $hcxLocalComputeProfile = Get-HCXComputeProfile -Name $HCXComputeProfileName
    New-HCXServiceMesh -SourceComputeProfile $hcxLocalComputeProfile -Destination $destination -DestinationComputeProfile $hcxRemoteComputeProfile -Service BulkMigration, DisasterRecovery, Interconnect, NetworkExtension, WANOptimization -Name $HCXServiceMeshName -SourceUplinkNetworkProfile $UplinkNetworkProfile
}
    
elseif (($HCXVDSName.Length -eq 0) -and ($vMotionRequired -match "True")) {
    New-HCXComputeProfile -ManagementNetworkProfile $managementNetworkProfile -vMotionNetworkProfile $vmotionNetworkProfile -vSphereReplicationNetworkProfile $ReplicationNetworkProfile -UplinkNetworkProfile $UplinkNetworkProfile -Name $HCXComputeProfileName -Service BulkMigration, DisasterRecovery, Interconnect, Vmotion, WANOptimization -Datastore $datastore -DeploymentResource $cluster -ServiceCluster $cluster
    Write-Host -ForegroundColor Green "`nCompute Profile created Successfully..."

    Write-Host -ForegroundColor Green "`nCreating Service mesh...`n--------------------------"
    $hcxLocalComputeProfile = Get-HCXComputeProfile -Name $HCXComputeProfileName
    New-HCXServiceMesh -SourceComputeProfile $hcxLocalComputeProfile -Destination $destination -DestinationComputeProfile $hcxRemoteComputeProfile -Service BulkMigration, DisasterRecovery, Interconnect, Vmotion, WANOptimization -Name $HCXServiceMeshName -SourceUplinkNetworkProfile $UplinkNetworkProfile
}
else {
    New-HCXComputeProfile -ManagementNetworkProfile $managementNetworkProfile -vMotionNetworkProfile $vmotionNetworkProfile -vSphereReplicationNetworkProfile $ReplicationNetworkProfile -UplinkNetworkProfile $UplinkNetworkProfile -Name $HCXComputeProfileName -Service BulkMigration, DisasterRecovery, Interconnect, WANOptimization -Datastore $datastore -DeploymentResource $cluster -ServiceCluster $cluster

    Write-Host -ForegroundColor Green "`nCreating Service mesh...`n--------------------------"
    $hcxLocalComputeProfile = Get-HCXComputeProfile -Name $HCXComputeProfileName
    New-HCXServiceMesh -SourceComputeProfile $hcxLocalComputeProfile -Destination $destination -DestinationComputeProfile $hcxRemoteComputeProfile -Service BulkMigration, DisasterRecovery, Interconnect, WANOptimization -Name $HCXServiceMeshName -SourceUplinkNetworkProfile $UplinkNetworkProfile
}

$ServiceMesh = Get-HCXServiceMesh 
write-host -ForegroundColor Green `n$($ServiceMesh.Service) "`nThe above mentioned services are enabled on Service Mesh" 
Sleep 30

#################################### Writing the Output file ####################################
Write-host -ForegroundColor Yellow ("`nWriting HCX Network profile details to excel file @ ")$path ("SheetName: HCXNetworkProfiles") 
Get-HCXNetworkProfile | Export-Excel $path -WorksheetName HCXNetworkProfiles
Write-host -ForegroundColor Yellow ("`nWriting HCX Compute profile details to excel file @ ")$path ("SheetName: HCXComputeProfiles") 
Get-HCXComputeProfile | Export-Excel $path -WorksheetName HCXComputeProfiles
Write-host -ForegroundColor Yellow ("`nWriting HCX Service Mesh details to excel file @ ")$path ("SheetName: ServiceMeshDetails") 
Get-HCXServiceMesh | Export-Excel $path -WorksheetName ServiceMeshDetails
#Disconnect-VIServer * -Confirm:$false
#Disconnect-HCXServer * -Confirm:$false