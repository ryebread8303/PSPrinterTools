#region import scripts
# Get public and private function definition files.
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files.
foreach ($import in @($Public + $Private)) {
    try {
        Write-Verbose "Importing $($import.FullName)"
        . $import.FullName
    } catch {
        Write-Error "Failed to import function $($import.FullName): $_"
    }
}

foreach ($file in $Public) {
    Export-ModuleMember -Function $file.BaseName
}
Export-ModuleMember -Alias *
#endregion import scripts
#region setup PrinterDB folder in ProgramData
$Config = Get-PrinterToolsConfig
$PrinterDBDataFolder = $Config.PrinterDBDataFolder
if(-not(test-path $PrinterDBDataFolder)){
    Write-Verbose "PrinterDB data folder does not exist, creating it at $PrinterDBDataFolder."
    new-item -path $PrinterDBDataFolder -ItemType "Directory"
}else{
    Write-Verbose "PrinterDB data folder exists."
}
#endregion setup PrinterDB folder in ProgramData
#set the enum used by Write-Log
enum LogLevel {
    Verbose
    Info
    Warning
    Error
    Critical
}
$LogLevel = [LogLevel]"Info"
#region set formatting for custom typenames
#this is used for limiting what displays to console for some Get- cmdlets
#without having to limit the data returned
$DHCPRecordTypeData = @{
    TypeName = "Printertools.DhcpRecord"
    DefaultDisplayPropertySet = "clientid","scopeid","ipaddress","addressstate","hostname","serverip"
}
$NPSTypeData = @{
    TypeName = "Printertools.NPSAccount"
    DefaultDisplayPropertySet = "samaccountname","enabled","distinguishedname","memberof"
}
Update-TypeData @DHCPRecordTypeData -Force
Update-TypeData @NPSTypeData -Force
#endregion set formatting for custom typenames