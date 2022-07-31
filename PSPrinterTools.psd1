#
# Module manifest for module 'PSPrinterTools'
#
# Generated by: O'Ryan Hedrick
#
# Generated on: 12/10/2020
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'PSPrinterTools.psm1'

# Version number of this module.
ModuleVersion = '1.7.4'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'dda8cdf0-44a5-481e-9623-d1b8400e53b9'

# Author of this module
Author = 'O''Ryan Hedrick'

# Company or vendor of this module
CompanyName = 'FLW NEC'

# Copyright statement for this module
Copyright = 'none'

# Description of the functionality provided by this module
Description = 'Tools used to manage printers at Ft Leonard Wood.'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @('Test-AsyncPing')

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
#ScriptsToProcess = @('Disable-BrowserCertCheck.ps1', 'Get-PrinterUIC.ps1', 'Get-UICFromOrg.ps1')

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
<#NestedModules = @(
    'FLWPrinterTools.psm1',
    'Disable-BrowserCertCheck.psm1',
    'Get-PrinterUIC.psm1',
    'Get-UICFromOrg.psm1',
    'Set-FFTLSVersion.psm1',
    'PDBMaint.psm1'
)#>

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport='*'
# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
#FileList = ''

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{
        ExternalModuleDependencies = 'ActiveDirectory'

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = @"
1.7.4:
* Fixed type in configuration file, SLQServer changed to SQLServer
1.7.3:
* Test-PrinterHealth: Fixed a bug where the NPS account details still didn't work when the IP address was provided.
1.7.2:
* removed requirement for admin privs from Remove-BulkPrinter so that the module can load on a non admin account. This will let Test-PrinterHealth and Test-Printerconnectivity work under normal accounts.
1.7.1:
* Test-PrinterHealth: Fixed issue preventing it from getting NPS information when provided the IP instead of the MAC.
1.7.0:
* Import-PrintServerData: No longer stripping dashes from reservation clientid. This was causing issues with uploading the data to SharePoint.
* Import-PrintServerData: Switched from PSJobs to using a runspace pool for a slight performance boost.
* Get-PrinterDHCPReservation: now accepts an IPAddress argument or a MACAddress argument
* Test-PrinterHealth: Now checks for the NPS account.
* Added the new servers to the default config
* Added SQL Server to the config. This will be used in Update-PrinterLog and Get-UICFromOrg
* Get-UICFromOrg: Now uses the config file for the SQL server hostname.
* Get-PrinterDHCPLease: New function, copies functionality from Get-FLWDHCPLease.
* Remove-BulkPrinter: uncommented line for removing NPS accounts
* Write-Log: Uses the [LogLevel] enum to keep input consistent across the module.
* Write-Log: Can now output to multiple targets
* Update-PrinterLog: Uses Write-Log for it's logging
* Update-PrinterLog: Now uses the config file for the SQL server hostname.
* Import-PrintServerData: Uses Write-Log for it's logging
* Test-TCPSocket: new function added to reduce time spent waiting on TCP port checks
1.6.0:
* Update-PrinterLog: Now is able to copy the new records directly into the SQL server, SSMS is no longer needed.
1.5.3:
* Update-PrinterLog: Testing the upload to SQL. Doesn't work yet.
* Test-PrinterNPSAccount: changed a break statement to return to prevent premature ending of Add-PrinterNPSAccount
* New function: Get-PrinterNPSAccount: fetches NPS account information for a printer given a MAC address
* New function: Get-PrinterDHCPReservation: fetches reservations from the printer subnets for a given MAC
* Add-PrinterNPSAccount: now gives a non-terminating error if an account already exists so that it can be used in a loop to add multiple printers
* Add-PrinterDHCPReservation: added error catching to convert an existing lease into a reservation
1.5.2:
* Add-PrinterToNPS: Renamed to Add-PrinterNPSAccount, and it now checks if an account exists before
  trying to create a new one.
* Add-PrinterDHCPReservation: Removed a redundant Read-Host line. Marked the Description parameter as mandatory. It 
  now checks if a reservation exists before trying to create a new one. Changed alias to apdhcp, fitting the scheme set by apnps.
* Renamed Test-FLWPrinterConnectivity to Test-PrinterConnectivity
1.5.1:
* Exported function aliases
1.5:
* Changed structure of the module for easier maintenance, each function is in it's own file.
* Added comment based help to all the included functions.
* Added missing support function: Get-PrinterLastUser.ps1
* Added function to remove stale printers:Remove-BulkPrinter.ps1
* Added function to manage DHCP reservations:Add-PrinterDHCPReservation,Remove-PrinterDHCPReservation,Test-PrinterDHCPReservation
1.4:
* Added functions to add a MAC to NPS and test if a MAC is in NPS:Add-PrinterToNPS and Test-PrinterNPSAccount.
1.3: 
* Added functions from PDBMaint for use in PrinterDB updates.
* Consolidated paths and variables to an separate config file.
* Test-FLWPrinterConnectivity now filters out devices that don't have an IP Address listed.
1.2: 
* Added Set-FFTLSVersion command to set the Firefox security.tls.version.min setting.
"@

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

