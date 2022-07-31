#Requires -Modules "Get-FLWDHCPLease","PrintManagement"
<#
.SYNOPSIS
    Script removes a list of printers from AD, DHCP, and the print servers.
.DESCRIPTION
    This list of stale printers is generated in the PrinterDB MS Access front end, and should include printers that have not responded to ping in the last 45 days. Each printer in the list has it's NPS account, DHCP Reservation, print queue, and print port deleted from the relevant servers.
.NOTES
    AUTHOR: O'Ryan R Hedrick
    COMPANY: Ft Leonard Wood Network Enterprise Center
    LAST UPDATE: 22 DEC 2021
    TARGET AUDIENCE: Printer Administrators
#>
function Remove-BulkPrinter {
    [cmdletbinding(SupportsShouldProcess=$true)]
    param
    (
        #The path to a file exported from PrinterDB listing the printers to be removed from the systems.
        [string]
        $InputFile
    )
    $Config = Get-PrinterToolsConfig
    $DhcpServer = $Config.DHCPServers[0]
    $PrintServers = $Config.PrintServers
    function Get-PrinterList
    {
        param($InputFile)
        Import-csv $inputfile
    }
    function Remove-PrinterDHCPReservation
    {
        param
        (
            $MacList,
            $ComputerName
        )
        $reservations = Get-FLWDHCPLease $MacList
        $reservations | Remove-DhcpServerv4Reservation -ComputerName $ComputerName
    }
    function Remove-PrinterNPSAccount
    {
        param($MacList)
        $MacList.replace('-','') | Get-ADUser | Remove-ADUser
    }
    function Remove-BulkPrinter
    {
        param
        (
            $PrinterList,
            $ServerList
        )
        Process
        { 
            foreach($Server in $ServerList)
            {
                Get-Printer $PrinterList.where($_.ServerName -eq $Server -and $_.QueueName -ne '').QueueName -ComputerName $server | Remove-Printer -ComputerName $Server
            }
        }
    }
    function Remove-BulkPrinterPort
    {
        param
        (
            $PrinterList,
            $ServerList
        )
        Process
        { 
            foreach($Server in $ServerList)
            {
                Get-PrinterPort $PrinterList.where($_.ServerName -eq $Server -and $_.PortName -ne '').PortName -ComputerName $server | Remove-PrinterPort -ComputerName $Server
            }
        }

    }

    $Printers = Get-PrinterList -InputFile $InputFile
    Remove-PrinterDHCPReservation -MacList $Printers.'Mac Address' -ComputerName $DhcpServer
    Remove-PrinterNPSAccount -MacList $Printers.'Mac Address'
    Remove-BulkPrinter -PrinterList $Printers -ServerList $PrintServers
    Remove-BulkPrinterPort -PrinterList $Printers -ServerList $PrintServers
}