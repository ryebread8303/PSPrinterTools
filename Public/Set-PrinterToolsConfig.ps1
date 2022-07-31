<#
.SYNOPSIS
Change the FLWPrinterTools configuration.
.DESCRIPTION
Data is stored in a JSON file included in the module. This function allows you to edit that file, or set it to default values.
.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 27 OCT 2021
INTENDED AUDIENCE: Printer administrators
#>
Function Set-PrinterToolsConfig {
    [cmdletbinding()]
    param(
        [Parameter(ParameterSetName="ConfigOption")]
        $DhcpServers,
        [Parameter(ParameterSetName="ConfigOption")]
        $PrintServers,
        [Parameter(ParameterSetName="ConfigOption")]
        $PrintersMABGroup,
        [Parameter(ParameterSetName="ConfigOption")]
        $PrinterIPScopes,
        [Parameter(ParameterSetName="ConfigOption")]
        $USARCPrintersMABGroup,
        [Parameter(ParameterSetName="ConfigOption")]
        $PrinterDBDataFolder,
        [Parameter(ParameterSetName="Default")]
        [switch]$Default
    )
    $ConfigDir = "$PSScriptRoot\Config"
    #switching to JSON because there's an export function for it
    #$ConfigFileName = "PrinterToolsConfig.psd1"
    $ConfigFileName = "PrinterToolsConfig.json"
    $ConfigPath = Join-Path $ConfigDir $ConfigFileName

    $DefaultConfigPSD =@"
@{
    DHCPServers = "155.9.29.8","155.9.29.110"
    PrintServers = "leonpsvs2","leonpsvs4","leonpsfalcon"
    PrintersMABGroup = "FLW_NPS_PRINTERS"
    USARCPrintersMABGroup = "FLW_NPS_USARC_Printers"
    PrinterIPScopes = "158.7.46.0","158.7.48.0","158.7.50.0","158.7.52.0","158.7.54.0","158.7.55.0"
    PrinterDBDataFolder = "C:\ProgramData\PrinterDB"
}
"@
    $DefaultConfig = @"
{
    "DHCPServers": ["155.9.29.8","155.9.29.110"],
    "PrintServers":["leonpsvs2","leonpsvs4","leonpsfalcon"],
    "PrintersMABGroup" : "FLW_NPS_PRINTERS",
    "USARCPrintersMABGroup":"FLW_NPS_USARC_Printers",
    "PrinterIPScopes" : ["158.7.46.0","158.7.48.0","158.7.50.0","158.7.52.0","158.7.54.0","158.7.55.0"],
    "PrinterDBDataFolder" : "C:\\ProgramData\\PrinterDB"
}
"@
    if ($Default) {
        Set-Content $ConfigPath -Value $DefaultConfig
        break
    }
    $config = Get-PrinterToolsConfig
    if($DhcpServers){
        $config.DhcpServers = $DhcpServers
    }
    if($PrintServers){
        $config.PrintServers = $PrintServers
    }
    if($PrintersMABGroup){
        $config.PrintersMABGroup = $PrintersMABGroup
    }
    if($PrinterIPScopes){
        $config.PrinterIPScopes = $PrinterIPScopes
    }
    if($USARCPrintersMABGroup){
        $config.USARCPrintersMABGroup = $USARCPrintersMABGroup
    }
    if($PrinterDBDataFolder){
        $config.PrinterDBDataFolder = $PrinterDBDataFolder
    }
    $config | ConvertTo-JSON | set-content -Path $ConfigPath
}
