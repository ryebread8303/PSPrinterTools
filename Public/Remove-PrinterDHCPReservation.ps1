<#
.SYNOPSIS
Removes a reservation from all DHCP servers.
.DESCRIPTION
Adapted from the NID PowerShell script. Uses the list of DHCP servers from FLWPrinterTools configuration file and removes a given reservation from each server listed there.
.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 28 OCT 2021
INTENDED AUDIENCE: Printer administrators
#>
function Remove-PrinterDHCPReservation {
    [CmdletBinding()]
    [Alias("rpdr")]
    param(
        [Parameter(Mandatory=$true)]
        $ScopeID,
        [Parameter(Mandatory=$true)]
        [Alias("MACAddress")]
        $ClientID
    )
    $Config = Get-PrinterToolsConfig
    Foreach ($server in $Config.DHCPServers) {
        Remove-DhcpServerv4Reservation -ComputerName $server -ScopeId $ScopeID -ClientId $ClientID
    }
}
