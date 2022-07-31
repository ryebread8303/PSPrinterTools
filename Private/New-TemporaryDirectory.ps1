<#
.SYNOPSIS
Helper function to create a temp directory
.DESCRIPTION
Powershell includes a cmdlet to create a new temp file, but not a directory. This cmdlet creates a directory
.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 
INTENDED AUDIENCE: Script writers
#>
function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}
