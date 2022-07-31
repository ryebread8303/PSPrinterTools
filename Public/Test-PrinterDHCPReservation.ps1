<#
.SYNOPSIS
Check if a printer has a reservation already
.DESCRIPTION
This script checks every printer subnet for reservations matching a given MAC address.
.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 29 OCT 2021
INTENDED AUDIENCE: Printer administrators
#>
function Test-PrinterDHCPReservation {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        $MACAddress
    )
    $Config = Get-PrinterToolsConfig
    $Found = $False
    foreach ($scope in $Config.PrinterIPScopes){
        $reservation = get-dhcpserverv4reservation -computername $Config.DHCPServers[0] -ClientID $MACAddress -ScopeID $scope -erroraction "SilentlyContinue"
        if($reservation){$Found = $true}
    }
    $Found
}