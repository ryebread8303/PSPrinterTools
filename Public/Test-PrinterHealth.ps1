<#
.SYNOPSIS
Test whether a printer is on the network, and whether necessary infrastructure is set up.
.DESCRIPTION
Checks the status of the following items:
* NPS account in AD
* DHCP reservation
* Ping response on printer's IP address
* TCP connectivity to ports 80,443, and 9100

.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 26 APR 2022
INTENDED AUDIENCE: Printer administrators
#>
function Test-PrinterHealth {
    [CmdletBinding()]
    param(
        [parameter(mandatory=$true,ParameterSetname = "IPAddress")]
        [alias("IP")]
        [string]
        $IPAddress,
        [parameter(mandatory=$true,ParameterSetName = "MACAddress")]
        [alias("MAC")]
        [string]
        $MACAddress
    )
    If ($IPAddress) {
        #if given the IP, fetch the MAC
        #placeholder
        $DHCPReservation = Get-PrinterDHCPReservation -IPAddress $IPAddress
        $MACAddress = $DHCPReservation.ClientID
    }
    If ($MACAddress) {
        #if given the MAC, fetch DHCP reservation
        if (Test-PrinterDhcpReservation $MACAddress){
            $DHCPReservation = get-printerdhcpreservation -MACAddress $MACAddress
            $IPAddress = $DHCPReservation.IPAddress.IPAddressToString
        } else {
            Write-Log -Console -Severity Warning -Message "Reservation not found."
            $DHCPReservation = $null
        }
    }
    $NPSAccount = Get-PrinterNPSAccount $MACAddress
    if ($null -eq $DHCPReservation){
        $PrinterStatus = $null
    } else {
        $PrinterStatus = [pscustomobject]@{
            ReservedMAC = $DHCPReservation.ClientID
            ReservedIP = $DHCPReservation.IPAddress.IPAddressToString
            ReservedHostName = $DHCPReservation.Name
            hasNPSAccount = Test-PrinterNPSAccount $MACAddress
            NPSAccountEnabled = $NPSAccount.Enabled
            Online = (Test-QuickPing $IPAddress)
            Port80Responds = (Test-TCPSocket -hostname $IPAddress -Port 80)
            Port443Responds = (Test-TCPSocket -hostname $IPAddress -Port 443)
            Port9100Responds = (Test-TCPSocket -hostname $IPAddress -Port 9100)
        }
    }
    #$PrinterStatus.psobject.typenames.Insert(0,"PrinterTools.PrinterStatus")
    $PrinterStatus
}