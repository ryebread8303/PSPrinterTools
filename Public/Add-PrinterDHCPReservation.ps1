<#
.SYNOPSIS
Add a DHCP reservation for a printer
.DESCRIPTION
Code taken and adapted from the NID PowerShell script. Wraps the reservation creation command in a function that fills in standard options.
.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 28 OCT 2021
INTENDED AUDIENCE: Printer Administrators
#>
function Add-PrinterDHCPReservation {
    [CmdletBinding()]
    [Alias("apdhcp","ares")]
    param(
        #The IP Address you want to reserve.
        [Parameter(Mandatory=$true)]
        [ipaddress]
        $IPAddress,
        #The MAC address of the printer.
        [Parameter(Mandatory=$true)]
        $MACAddress,
        #The desired hostname in the reservation.
        [Parameter(Mandatory=$true)]
        $Hostname,
        #Device description. Probably should be the print queue display name.
        [Parameter(Mandatory=$true)]
        $Description
    )
    $Config = Get-PrinterToolsConfig
    #throw an exception and quit the script if a reservation already exists
    #if (Test-PrinterDHCPReservation $MACAddress){throw [System.Data.DuplicateNameException]::New("A reservation for $MACAddress already exists.")}
    try{
        Add-DhcpServerv4Reservation -ComputerName $Config.DHCPServers[0] -ScopeID $IPAddress -IPAddress $IPAddress -ClientId $MACAddress -Description $Description -Name "$Hostname.$($Config.Domain)" -erroraction "Stop"
    } catch [Microsoft.Management.Infrastructure.CimException] {
        #get-PrinterDHCPReservation $MACAddress | add-DhcpServerv4Reservation -computername $Config.DHCPServers[0]
        #get-PrinterDHCPReservation $MACAddress | set-DhcpServerv4Reservation -hostname $Hostname -computername $Config.DHCPServers[0]
        $PSItem.Exception.Message
        $PSItem.ScriptStackTrace
    }
}