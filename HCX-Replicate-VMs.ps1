###############################################################################
<#
This script will help to Replicate Multiple Virtual machines from the source vCenter to Destination vCenter.
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
Write-host -ForegroundColor Green "`nReading the Excel file"
$Data = Import-Excel $path -WorksheetName ReplicateVMTemplate

for ($i = 0; $i -lt $Data.Count - 1; $i++) {
    $ServerName = $Data[$i].ServerName
    $SourceSite = $Data[$i].SourceSite
    $DestinationSite = $Data[$i].DestinationSite
    $DestinationCompute = $Data[$i].DestinationCompute
    $DestinationDataStore = $Data[$i].DestinationDataStore
    $TargetDataCenter = $Data[$i].TargetDataCenter
    $NetworkCompressionEnabled = $Data[$i].NetworkCompressionEnabled
    $RPOIntervalMinutes = $Data[$i].RPOIntervalMinutes
    $SnapshotIntervalMinutes = $Data[$i].SnapshotIntervalMinutes
    $SnapshotNumber = $Data[$i].SnapshotNumber

    Write-host -ForegroundColor Yellow "`nAdding VM at Row $i $ServerName for replication..."
    Write-host -ForegroundColor Yellow "------------------------------------------------" 

    #####HCX Call#####
    $SrcSite = Get-HCXSite -Source $SourceSite
    $DstSite = Get-HCXSite -Destination $DestinationSite
    $vm = Get-HCXVM -Name $ServerName -Site $SrcSite
    $TargetCluster = Get-HCXContainer -Name $DestinationCompute -Site $DstSite
    $TargetDatastore = Get-HCXDatastore -Name $DestinationDataStore -Site $DstSite
    $TargetDataCenter = Get-HCXContainer -Name $TargetDataCenter -Site $DstSite -Type Datacenter

    #####Network Mapping#####
    $DestNetwork1 = $Data[$i].DestinationNetwork1
    $DestNetwork2 = $Data[$i].DestinationNetwork2
    $DestNetwork3 = $Data[$i].DestinationNetwork3
    $DestNetwork4 = $Data[$i].DestinationNetwork4
    $SourceNetwork = $vm.Network
    $NumberofNICS = $SourceNetwork.Count

    #################################### Replicating Workloads with 1 Source Nic ####################################
    if ($NumberofNICS -eq 1) {

        $SourceNetwork1 = $vm.Network[0]

        $SrcNetwork1 = Get-HCXNetwork -Name $SourceNetwork1 -Site $SrcSite

        $DstNetwork1 = Get-HCXNetwork -Name $DestNetwork1 -Site $DstSite

        $TarNetwork1 = New-HCXNetworkMapping -SourceNetwork $SrcNetwork1 -DestinationNetwork $DstNetwork1
                
        $newReplication = New-HCXReplication -SourceSite $SrcSite -DestinationSite $DstSite -VM $vm -NetworkMapping $TarNetwork1 -RPOIntervalMinutes $RPOIntervalMinutes -SnapshotIntervalMinutes $SnapshotIntervalMinutes -SnapshotNumber $SnapshotNumber -TargetComputeContainer $TargetCluster -TargetDataCenter $TargetDataCenter -TargetDatastore $TargetDatastore -NetworkCompressionEnabled  ([System.Convert]::ToBoolean($NetworkCompressionEnabled))
        
        try {
            $drvalidation = Test-HCXReplication -Replication $newReplication
            Write-Host -ForegroundColor Yellow "Replication Validation completed"
            $drvalidation.ValidationResult 
            Start-HCXReplication -Replication $newReplication -Confirm:$false
            Write-Host -ForegroundColor Green ("`nReplication initiated on $vm successfully")
        }
        catch {
            Write-host -ForegroundColor Red "`nReplication cannot be initiated for $ServerName at Row $i due to errors..." 
            Write-host -ForegroundColor Red $_.Exception.Message
        }
    }

    #################################### Replicating Workloads with 2 Source Nic ####################################
    elseif ($NumberofNICS -eq 2) {
        
        $SourceNetwork1 = $vm.Network[0]
        $SourceNetwork2 = $vm.Network[1]

        $SrcNetwork1 = Get-HCXNetwork -Name $SourceNetwork1 -Site $SrcSite
        $SrcNetwork2 = Get-HCXNetwork -Name $SourceNetwork2 -Site $SrcSite 

        $DstNetwork1 = Get-HCXNetwork -Name $DestNetwork1 -Site $DstSite 
        $DstNetwork2 = Get-HCXNetwork -Name $DestNetwork2 -Site $DstSite 

        $TarNetwork1 = New-HCXNetworkMapping -SourceNetwork $SrcNetwork1 -DestinationNetwork $DstNetwork1
        $TarNetwork2 = New-HCXNetworkMapping -SourceNetwork $SrcNetwork2 -DestinationNetwork $DstNetwork2

        $newReplication = New-HCXReplication -SourceSite $SrcSite -DestinationSite $DstSite -VM $vm -NetworkMapping @($TarNetwork1, $TarNetwork2) -RPOIntervalMinutes $RPOIntervalMinutes -SnapshotIntervalMinutes $SnapshotIntervalMinutes -SnapshotNumber $SnapshotNumber -TargetComputeContainer $TargetCluster -TargetDataCenter $TargetDataCenter -TargetDatastore $TargetDatastore -NetworkCompressionEnabled  ([System.Convert]::ToBoolean($NetworkCompressionEnabled))
        $drvalidation = Test-HCXReplication -Replication $newReplication
        try {
            $drvalidation = Test-HCXReplication -Replication $newReplication
            Write-Host -ForegroundColor Yellow "Replication Validation completed"
            $drvalidation.ValidationResult 
            Start-HCXReplication -Replication $newReplication -Confirm:$false
            Write-Host -ForegroundColor Green ("`nReplication initiated on $vm successfully")
        }
        catch {
            Write-host -ForegroundColor Red "`nReplication cannot be initiated for $ServerName at Row $i due to errors..." 
            Write-host -ForegroundColor Red $_.Exception.Message
        }
    }
    #################################### Replicating Workloads with 3 Source Nic ####################################
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
        
        $newReplication = New-HCXReplication -SourceSite $SrcSite -DestinationSite $DstSite -VM $vm -NetworkMapping @($TarNetwork1, $TarNetwork2, $TarNetwork3) -RPOIntervalMinutes $RPOIntervalMinutes -SnapshotIntervalMinutes $SnapshotIntervalMinutes -SnapshotNumber $SnapshotNumber -TargetComputeContainer $TargetCluster -TargetDataCenter $TargetDataCenter -TargetDatastore $TargetDatastore -NetworkCompressionEnabled  ([System.Convert]::ToBoolean($NetworkCompressionEnabled))
        try {
            $drvalidation = Test-HCXReplication -Replication $newReplication
            Write-Host -ForegroundColor Yellow "Replication Validation completed"
            $drvalidation.ValidationResult 
            Start-HCXReplication -Replication $newReplication -Confirm:$false
            Write-Host -ForegroundColor Green ("`nReplication initiated on $vm successfully")
        }
        catch {
            Write-host -ForegroundColor Red "`nReplication cannot be initiated for $ServerName at Row $i due to errors..." 
            Write-host -ForegroundColor Red $_.Exception.Message
        }  
    }
    #################################### Replicating Workloads with 4 Source Nic ####################################
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

        $newReplication = New-HCXReplication -SourceSite $SrcSite -DestinationSite $DstSite -VM $vm -NetworkMapping @($TarNetwork1, $TarNetwork2, $TarNetwork3, $TarNetwork4) -RPOIntervalMinutes $RPOIntervalMinutes -SnapshotIntervalMinutes $SnapshotIntervalMinutes -SnapshotNumber $SnapshotNumber -TargetComputeContainer $TargetCluster -TargetDataCenter $TargetDataCenter -TargetDatastore $TargetDatastore -NetworkCompressionEnabled  ([System.Convert]::ToBoolean($NetworkCompressionEnabled))
        try {
            $drvalidation = Test-HCXReplication -Replication $newReplication
            Write-Host -ForegroundColor Yellow "Replication Validation completed"
            $drvalidation.ValidationResult 
            Start-HCXReplication -Replication $newReplication -Confirm:$false
            Write-Host -ForegroundColor Green ("`nReplication initiated on $vm successfully")
        }
        catch {
            Write-host -ForegroundColor Red "`nReplication cannot be initiated for $ServerName at Row $i due to errors..." 
            Write-host -ForegroundColor Red $_.Exception.Message
        }
    }
    else {
        Write-Host -ForegroundColor Red "Number of Source Network cards on the $vm is more than 4, Network mapping cannot be set. Replication for $vm will be skipped, please run manually"
    }
} 
Write-host -ForegroundColor Yellow ("`nPreparing the Replicating VMs Output file, check the file $path SheetName: ReplicatedVMsOutput") 
sleep 60
Get-HCXReplication | Export-Excel $path -WorksheetName ReplicatedVMsOutput
#Disconnect-HCXServer * -Confirm:$false
