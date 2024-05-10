###############################################################################
<#
This script will help to Migrate Multiple Virtual machines from the source vCenter to Destination vCenter.
Actions to be taken before running the script:
1: Install PowerCli module on Powershell: Install-Module VMware.PowerCLI -Scope CurrentUser -SkipPublisherCheck
2: Import Excel module on Powershell: Install-Module -Name ImportExcel -Scope CurrentUser
#>
################################################################################

################################################Ignoring Invaid Certs################################################
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

####################################Connecting to Onprem HCX Connector Server####################################
Write-Host -ForegroundColor Yellow "`nConnecting to Onprem HCX Connector Server"
while (1) {
    $Server = Read-Host -Prompt 'Enter Onprem HCX Connector Server IP'
    $Cre = Get-Credential
    Write-Host "Connecting to HCX Connector:" $Server"..."
    $HCXconnection = Connect-HCXServer -server $Server -credential $Cre
    if ($HCXconnection.Name -match $Server) {
        Write-Host -ForegroundColor Green "`nConnection to HCX Connector Server: "$Server" has been extablished successfully."
        break
    }
    else {
        Write-Host -ForegroundColor Red "`nConnection to HCX Connector Server: "$Server" failed, retry."
    }
}

#################################### Browsing the required files ####################################
Write-host -ForegroundColor Green "Choose the excel file to feed the data to the script"

Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$FileBrowser.filter = 'SpreadSheet (*.xlsx)|*.xlsx'
[void]$FileBrowser.ShowDialog()
$path = $FileBrowser.FileName 

#################################### Reading the Variables from Excel File ####################################
Write-host -ForegroundColor Green "Reading the Excel file"

$Data = Import-Excel $path -WorksheetName MigrateVMTemplate


for ($i = 0; $i -lt $Data.Count - 1; $i++) {

    $ServerName = $Data[$i].ServerName
    $SourceSite = $Data[$i].SourceSite
    $DestSite = $Data[$i].DestinationSite
    $DestFolder = $Data[$i].containerFolder
    $DestinationCompute = $Data[$i].DestinationCompute
    $Datastore = $Data[$i].DestinationDataStore
    $RemoveISO = $Data[$i].RemoveISO
    $RemoveSnapshots = $Data[$i].RemoveSnapshots
    $RetainMac = $Data[$i].RetainMac
    $UpgradeVMTools = $Data[$i].UpgradeVMTools
    $MigrationType = $Data[$i].MigrationType
    $DiskProvisionType = $Data[$i].DiskProvisionType

    #####CutOver Scheduling#####
    $StartTime = $Data[$i].StartTime
    $EndTime = $Data[$i].EndTime

    Write-host -ForegroundColor Yellow "`nAdding VM at Row $i $ServerName for $MigrationType Migration..." 
    Write-host -ForegroundColor Yellow "------------------------------------------------" 

    #####HCX Call#####
    $SrcSite = Get-HCXSite -Source $SourceSite
    $DstSite = Get-HCXSite -Destination $DestSite
    $vm = Get-HCXVM -Name $ServerName -Site $SrcSite
    $TargetCluster = Get-HCXContainer -Name $DestinationCompute -Site $DstSite
    $TargetFolder = Get-HCXContainer -Name $DestFolder -Site $DstSite
    $TargetDatastore = Get-HCXDatastore -Name $Datastore -Site $DstSite

    #####Network Mapping#####
    
    $DestNetwork1 = $Data[$i].DestinationNetwork1
    $DestNetwork2 = $Data[$i].DestinationNetwork2
    $DestNetwork3 = $Data[$i].DestinationNetwork3
    $DestNetwork4 = $Data[$i].DestinationNetwork4
    $SourceNetwork = $vm.Network
    $NumberofNICS = $SourceNetwork.Count



    #################################### Migrating Workloads with 1 Source Nic ####################################
    if ($NumberofNICS -eq 1) {

        $SourceNetwork1 = $vm.Network[0]

        $SrcNetwork1 = Get-HCXNetwork -Name $SourceNetwork1 -Site $SrcSite   

        $DstNetwork1 = Get-HCXNetwork -Name $DestNetwork1 -Site $DstSite 

        $TarNetwork1 = New-HCXNetworkMapping -SourceNetwork $SrcNetwork1 -DestinationNetwork $DstNetwork1
        
        $newMigration = New-HCXMigration -SourceSite $SrcSite -DestinationSite $DstSite -VM $vm -MigrationType $MigrationType -DiskProvisionType $DiskProvisionType -TargetComputeContainer $TargetCluster -TargetDatastore $TargetDatastore -ScheduleStartTime $StartTime -ScheduleEndTime $EndTime -NetworkMapping $TarNetwork1 -UpgradeVMTools ([System.Convert]::ToBoolean($UpgradeVMTools)) -RemoveISOs ([System.Convert]::ToBoolean($RemoveISO)) -ForcePowerOffVm $True -RetainMac ([System.Convert]::ToBoolean($RetainMac)) -UpgradeHardware $False -RemoveSnapshots ([System.Convert]::ToBoolean($RemoveSnapshots)) -Folder $TargetFolder
        try {
            $migrationvalidation = Test-HCXMigration -Migration $newMigration -ErrorAction:Inquire
            Write-Host -ForegroundColor Yellow "Migration Validation completed"
            $migrationvalidation.ValidationResult
            Start-HCXMigration -Migration $newMigration -Confirm:$false
            Write-Host -ForegroundColor Green ("`nMigration initiated on $vm successfully")
        }
        catch {
            Write-host -ForegroundColor Red "`nMigration cannot be initiated for $ServerName at Row $i due to errors..." 
            Write-host -ForegroundColor Red $_.Exception.Message
        }
    }
    #################################### Migrating Workloads with 2 Source Nic ####################################
    elseif ($NumberofNICS -eq 2) {
        
        $SourceNetwork1 = $vm.Network[0]
        $SourceNetwork2 = $vm.Network[1]

        $SrcNetwork1 = Get-HCXNetwork -Name $SourceNetwork1 -Site $SrcSite
        $SrcNetwork2 = Get-HCXNetwork -Name $SourceNetwork2 -Site $SrcSite

        $DstNetwork1 = Get-HCXNetwork -Name $DestNetwork1 -Site $DstSite
        $DstNetwork2 = Get-HCXNetwork -Name $DestNetwork2 -Site $DstSite

        $TarNetwork1 = New-HCXNetworkMapping -SourceNetwork $SrcNetwork1 -DestinationNetwork $DstNetwork1
        $TarNetwork2 = New-HCXNetworkMapping -SourceNetwork $SrcNetwork2 -DestinationNetwork $DstNetwork2

        $newMigration = New-HCXMigration -SourceSite $SrcSite -DestinationSite $DstSite -VM $vm -MigrationType $MigrationType -DiskProvisionType $DiskProvisionType -TargetComputeContainer $TargetCluster -TargetDatastore $TargetDatastore -ScheduleStartTime $StartTime -ScheduleEndTime $EndTime -NetworkMapping @($TarNetwork1, $TarNetwork2) -UpgradeVMTools ([System.Convert]::ToBoolean($UpgradeVMTools)) -RemoveISOs ([System.Convert]::ToBoolean($RemoveISO)) -ForcePowerOffVm $True -RetainMac ([System.Convert]::ToBoolean($RetainMac)) -UpgradeHardware $False -RemoveSnapshots ([System.Convert]::ToBoolean($RemoveSnapshots)) -Folder $TargetFolder
        try {
            $migrationvalidation = Test-HCXMigration -Migration $newMigration -ErrorAction:Inquire
            Write-Host -ForegroundColor Yellow "Migration Validation completed"
            $migrationvalidation.ValidationResult
            Start-HCXMigration -Migration $newMigration -Confirm:$false
            Write-Host -ForegroundColor Green ("`nMigration initiated on $vm successfully")
        }
        catch {
            Write-host -ForegroundColor Red "`nMigration cannot be initiated for $ServerName at Row $i due to errors..." 
            Write-host -ForegroundColor Red $_.Exception.Message
        }
    }
    #################################### Migrating Workloads with 3 Source Nic ####################################

    elseif ($NumberofNICS -eq 3) {

        $SourceNetwork1 = $vm.Network[0]
        $SourceNetwork2 = $vm.Network[1]
        $SourceNetwork3 = $vm.Network[2]

        $SrcNetwork1 = Get-HCXNetwork -Name $SourceNetwork1 -Site $SrcSite
        $SrcNetwork2 = Get-HCXNetwork -Name $SourceNetwork2 -Site $SrcSite
        $SrcNetwork3 = Get-HCXNetwork -Name $SourceNetwork3 -Site $SrcSite
    
        $DstNetwork1 = Get-HCXNetwork -Name $DestNetwork1 -Site $DstSite
        $DstNetwork2 = Get-HCXNetwork -Name $DestNetwork2 -Site $DstSite
        $DstNetwork3 = Get-HCXNetwork -Name $DestNetwork3 -Site $DstSite
    
        $TarNetwork1 = New-HCXNetworkMapping -SourceNetwork $SrcNetwork1 -DestinationNetwork $DstNetwork1
        $TarNetwork2 = New-HCXNetworkMapping -SourceNetwork $SrcNetwork2 -DestinationNetwork $DstNetwork2
        $TarNetwork3 = New-HCXNetworkMapping -SourceNetwork $SrcNetwork3 -DestinationNetwork $DstNetwork3
        
        $newMigration = New-HCXMigration -SourceSite $SrcSite -DestinationSite $DstSite -VM $vm -MigrationType $MigrationType -DiskProvisionType $DiskProvisionType -TargetComputeContainer $TargetCluster -TargetDatastore $TargetDatastore -ScheduleStartTime $StartTime -ScheduleEndTime $EndTime -NetworkMapping @($TarNetwork1, $TarNetwork2, $TarNetwork3) -UpgradeVMTools ([System.Convert]::ToBoolean($UpgradeVMTools)) -RemoveISOs ([System.Convert]::ToBoolean($RemoveISO)) -ForcePowerOffVm $True -RetainMac ([System.Convert]::ToBoolean($RetainMac)) -UpgradeHardware $False -RemoveSnapshots ([System.Convert]::ToBoolean($RemoveSnapshots)) -Folder $TargetFolder
        try {
            $migrationvalidation = Test-HCXMigration -Migration $newMigration -ErrorAction:Inquire
            Write-Host -ForegroundColor Yellow "Migration Validation completed"
            $migrationvalidation.ValidationResult
            Start-HCXMigration -Migration $newMigration -Confirm:$false
            Write-Host -ForegroundColor Green ("`nMigration initiated on $vm successfully")
        }
        catch {
            Write-host -ForegroundColor Red "`nMigration cannot be initiated for $ServerName at Row $i due to errors..." 
            Write-host -ForegroundColor Red $_.Exception.Message
        }

    }
    #################################### Migrating Workloads with 4 Source Nic ####################################
    elseif ($NumberofNICS -eq 4) {

        $SourceNetwork1 = $vm.Network[0]
        $SourceNetwork2 = $vm.Network[1]
        $SourceNetwork3 = $vm.Network[2]
        $SourceNetwork4 = $vm.Network[3]

        $SrcNetwork1 = Get-HCXNetwork -Name $SourceNetwork1 -Site $SrcSite
        $SrcNetwork2 = Get-HCXNetwork -Name $SourceNetwork2 -Site $SrcSite
        $SrcNetwork3 = Get-HCXNetwork -Name $SourceNetwork3 -Site $SrcSite
        $SrcNetwork4 = Get-HCXNetwork -Name $SourceNetwork4 -Site $SrcSite
    
        $DstNetwork1 = Get-HCXNetwork -Name $DestNetwork1 -Site $DstSite
        $DstNetwork2 = Get-HCXNetwork -Name $DestNetwork2 -Site $DstSite
        $DstNetwork3 = Get-HCXNetwork -Name $DestNetwork3 -Site $DstSite
        $DstNetwork4 = Get-HCXNetwork -Name $DestNetwork4 -Site $DstSite
    
        $TarNetwork1 = New-HCXNetworkMapping -SourceNetwork $SrcNetwork1 -DestinationNetwork $DstNetwork1
        $TarNetwork2 = New-HCXNetworkMapping -SourceNetwork $SrcNetwork2 -DestinationNetwork $DstNetwork2
        $TarNetwork3 = New-HCXNetworkMapping -SourceNetwork $SrcNetwork3 -DestinationNetwork $DstNetwork3
        $TarNetwork4 = New-HCXNetworkMapping -SourceNetwork $SrcNetwork4 -DestinationNetwork $DstNetwork4
        
        $newMigration = New-HCXMigration -SourceSite $SrcSite -DestinationSite $DstSite -VM $vm -MigrationType $MigrationType -DiskProvisionType $DiskProvisionType -TargetComputeContainer $TargetCluster -TargetDatastore $TargetDatastore -ScheduleStartTime $StartTime -ScheduleEndTime $EndTime -NetworkMapping @($TarNetwork1, $TarNetwork2, $TarNetwork3, $TarNetwork4) -UpgradeVMTools ([System.Convert]::ToBoolean($UpgradeVMTools)) -RemoveISOs ([System.Convert]::ToBoolean($RemoveISO)) -ForcePowerOffVm $True -RetainMac ([System.Convert]::ToBoolean($RetainMac)) -UpgradeHardware $False -RemoveSnapshots ([System.Convert]::ToBoolean($RemoveSnapshots)) -Folder $TargetFolder
        try {
            $migrationvalidation = Test-HCXMigration -Migration $newMigration -ErrorAction:Inquire
            Write-Host -ForegroundColor Yellow "Migration Validation completed"
            $migrationvalidation.ValidationResult
            Start-HCXMigration -Migration $newMigration -Confirm:$false
            Write-Host -ForegroundColor Green ("`nMigration initiated on $vm successfully")
        }
        catch {
            Write-host -ForegroundColor Red "`nMigration cannot be initiated for $ServerName at Row $i due to errors..." 
            Write-host -ForegroundColor Red $_.Exception.Message
        }
    }
    else {
        Write-Host -ForegroundColor Red "Number of Source Network cards on the $vm is more than 4, Network mapping cannot be set. Migration for $vm will be skipped, please run manually."
    }  
}

Write-host -ForegroundColor Yellow ("Preparing the Replicating VMs Output file, check the file $path SheetName: ReplicatedVMsOutput") 
sleep 60
Get-HCXMigration | Export-Excel $path -WorksheetName MigratedVMsOutput
#Disconnect-HCXServer * -Confirm:$false


