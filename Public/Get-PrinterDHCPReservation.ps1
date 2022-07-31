<#
.SYNOPSIS
Fetch a printer has a reservation already
.DESCRIPTION
This script checks every printer subnet for reservations matching a given MAC address.
.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 21 APR 2022
INTENDED AUDIENCE: Printer administrators
#>
function Get-PrinterDHCPReservation {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true,ParameterSetName="MAC")]
        [string]
        $MACAddress,
        [Parameter(Mandatory=$true,ParameterSetName="IP")]
        [string]
        $IPAddress
    )
    $Config = Get-PrinterToolsConfig
    if ( $MACAddress ) {
        foreach ($scope in $Config.PrinterIPScopes){
            $reservation 
            $reservation = get-dhcpserverv4reservation -computername $Config.DHCPServers[0] -ClientID $MACAddress -ScopeID $scope -erroraction "SilentlyContinue"
            if ($reservation) {break}
        }
    } elseif ($IPAddress) {
        $reservation = get-dhcpserverv4reservation -computername $Config.DHCPServers[0] -IPAddress $IPAddress -ErrorAction "SilentlyContinue"
    }
    $reservation.psobject.typenames.Insert(0,"Printertools.DHCPRecord")
    $reservation
}