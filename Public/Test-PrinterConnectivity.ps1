<#
.SYNOPSIS
Ping all printers in the environment.
.DESCRIPTION
Loads a list of printers exported from the PrinterDB MS Access front end, pings all those printers asyncronously using the Test-AsyncPing module, and then exports the results to a csv that can be uploaded to the PrinterDB by the MS Access front end.
.NOTES
AUTHOR: O'Ryan Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: SEP 2020
INTENDED AUDIENCE: Printer administrators maintaining the PrinterDB
#>
function Test-PrinterConnectivity {
    [CmdletBinding()]
    param()
    $printerdevices = import-csv "$PrinterDBDataFolder\PrinterDevices.csv" | Where-Object {$_."IP Address" -ne ""}
    $addresses = $printerdevices.'IP Address'
    $timestamp = get-date -format "MM/dd/yyyy"
    $results = $addresses | test-asyncping | Select-Object @{n='IP Address';e='name'},status,timestamp
    $results | foreach-object {$_.timestamp = $timestamp}
    $results | export-csv -path "$PrinterDBDataFolder\PingResults.csv" -NoTypeInformation
    #Read-Host "Run the ping results import from the PrinterDB frontend, then press enter here to continue."
}
