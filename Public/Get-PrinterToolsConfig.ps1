<#
.SYNOPSIS
Grab common settings used by the various tools in the FLWPrinterTools module.
.DESCRIPTION
Since many of these tools need the same data, like server IPs and Scope IDs, that data is stored in a JSON file and accessed as needed by each tool. 
.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 28 OCT 2021
INTENDED AUDIENCE: Printer administrators
#>
function Get-PrinterToolsConfig {
    [cmdletbinding()]
    param(
    )
    $ConfigDir = "$PSScriptRoot\Config"
    $ConfigFileName = "PrinterToolsConfig.json"
    $ConfigPath = Join-Path $ConfigDir $ConfigFileName

    if(test-path $ConfigPath)
    {
        ConvertFrom-JSON (Get-Content $ConfigPath -Raw)
    }
    else {
        Set-Content $ConfigPath -Value $DefaultConfig
        ConvertFrom-JSON (Get-Content $ConfigPath -Raw)
    }
}
