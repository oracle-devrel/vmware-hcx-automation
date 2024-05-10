#Script to Extend the source Distributed portgroups.
#PortGroups Should be from the Distributed Switch only.
#Portgroups Ephemeral Binding Not supported.
#Vlan is mandatory.


Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

$Server = Read-Host  -Prompt 'Enter HCX Server'
$Cre = Get-Credential
Write-Host -ForegroundColor Yellow "Connecting to HCXServer:" $Server"..."
try{
    VMware.VimAutomation.Hcx\Connect-HCXServer -server $server -credential $Cre -ErrorAction Stop
}
catch {
    throw "Connection to HCX Server failed!"
}
Write-Host -ForegroundColor Yellow "Connection to HCXServer: "$Server" has been extablished successfully."


Write-host -ForegroundColor Green "Choose the excel file to feed the data to the script"

Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$FileBrowser.filter = 'SpreadSheet (*.xlsx)|*.xlsx'
[void]$FileBrowser.ShowDialog()
$path = $FileBrowser.FileName 

#$Data = Import-csv $path -delimiter ","

$Data = Import-Excel $path -WorksheetName NetworkExtension

$i = 0
while ($i -lt $Data.Count-1) { 
        $SourceNetwork = $Data[$i].SourceNetwork
        $myAppliance = $Data[$i].myAppliance
        $SourceSite = $Data[$i].SourceSite
        $DestinationSite = $Data[$i].DestinationSite
        $DestNSXGateway = $Data[$i].DestNSXGateway
        $SubnetMask = $Data[$i].SubnetMask
        $DefaultGateway = $Data[$i].DefaultGateway
        $DstSite = Get-HCXSite -Destination $DestinationSite
        $SrcSite = Get-HCXSite -Source $SourceSite
        $SrcNetwork = Get-HCXNetwork -Name $SourceNetwork -Site $SrcSite
        $myL2CAppliance = Get-HCXAppliance -Type L2Concentrator -Name $myAppliance
        $myGateway = Get-HCXGateway -DestinationSite $DstSite -Name $DestNSXGateway
        New-HCXNetworkExtension -Appliance $myL2CAppliance -DestinationGateway $myGateway -DestinationSite $DstSite -GatewayIp $DefaultGateway -Netmask $SubnetMask -Network $SrcNetwork -SourceSite $SrcSite 
        $i++
} 
sleep 30
Get-HCXNetworkExtension

Write-host -ForegroundColor Yellow ("Preparing the Output file, check the file $path SheetName: ExtendedNetworksOutput") 


Get-HCXNetworkExtension | Export-Excel $path -WorksheetName ExtendedNetworksOutput 
#Disconnect-HCXServer * -Confirm:$false

