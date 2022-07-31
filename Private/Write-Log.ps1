<#
.SYNOPSIS
Helper function handles needed logging capability in scripts.
.DESCRIPTION
This function relies on an enum to be added to your script. Paste the following block 
into your script to add the needed enum:

enum LogLevel {
    Verbose
    Info
    Warning
    Error
    Critical
}

If you want to log INFO or VERBOSE entries, you'll need to set a $LogLevel variable 
to the appropriate level.
.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 20 APR 2022
INTENDED AUDIENCE: Script writers
TODO:
* Log to event viewer
#>
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(mandatory=$true)]
        [string]
        $Message,
        [Parameter(mandatory=$true)]
        [LogLevel]
        $Severity,
        [switch]
        $Temp,
        [switch]
        $Console,
        [string]
        $OutputFile
    )
    $DateTimeStamp = get-date -format yyyyMMdd:HHmmZz
    $DateStamp = get-date -format yyyyMMdd
    $Severity = $Severity
    #If the calling script has not set a $LogLevel variable, assume it should be set to Warning
    if ($null -eq $LogLevel){$LogLevel = [LogLevel]"Warning"}
    if ([LogLevel]$Severity -lt [LogLevel]$LogLevel) {
        Write-Debug "LogLevel is $LogLevel, Severity is $Severity"
        return
        }
    $ErrorColors = @{
        BackgroundColor = "Black"
        ForeGroundColor = "Red"
    }
    $WarningColors = @{
        BackgroundColor = "Black"
        ForeGroundColor = "Yellow"
    }
    function Add-LogToFile {
        param(
            [Parameter(mandatory=$true)]
            [string]
            $FilePath,
            [Parameter(mandatory=$true)]
            [LogLevel]
            $Severity,
            [Parameter(mandatory=$true)]
            [string]
            $Message,
            [int]
            $Attempt = 1
        )
        if ( $Attempt -gt 2 ) {Throw "Unable to write to log file."}
        if (-not (test-path $FilePath)){
            New-item -path $FilePath -ItemType File | out-null
        }
        try {
            Add-Content -path $FilePath -Value "$Severity : $DateTimeStamp : $Message" -ErrorAction "Stop"
        } catch {
            Start-Sleep 1
            Add-LogToFile $FilePath $Severity $Message ($Attempt ++)
        }
    }
    If($Temp) {
            $LogFilePath = "$env:temp\OutAllPrinters-$DateStamp.txt"
            Add-LogToFile $LogFilePath $Severity $Message
        }
    If($OutputFile){
        Add-LogToFile $OutputFile $Severity $Message
    }
    If($Console){
            $string = "$Severity : $DateTimeStamp : $Message"
            switch ($Severity) {
                'Critical' {Write-Host $string @ErrorColors}
                'Error' {Write-Host $string @ErrorColors}
                'Warning' {Write-Host $string @WarningColors}
                'Info' {Write-Host $string}
                'Verbose' {Write-Host $string}
            }
        }
}
