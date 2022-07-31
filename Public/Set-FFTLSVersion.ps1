<#
.SYNOPSIS
Edits the config file for Firefox to allow connecting to older version of TLS.
.DESCRIPTION
Firefox stores it's configuration in mozilla.cfg. This file contains a number of items that are locked to specific settings to satisfy STIG requirements. One of these items is security.tls.version.min, which is locked to 2. Unfortunately this prevents connecting to some old printers, so this function, when run as admin, lets you set the value to 1. Once you open Firefox, you can set the value back to 2 so that subsequent instances of Firefox comply with STIG requirements.
.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
INTENDED AUDIENCE: Printer administrators
LAST EDIT: 28 OCT 2021
Requires admin priviledges
#>
Function Set-FFTLSVersion {
    Param(
        #Desired value for security.tls.verion.min. This should be 1 or 2.
        [alias("MinVer")]
        [Parameter(Position=0,Mandatory=$true)]
        [ValidateSet("1","2")]
        [string]
        $MinimumVersion
    )
    #we only make a change if the current value is wrong, so here we set the wrong value that were looking for, and the right value that will replace the wrong value
    If($MinimumVersion -eq 1){$ReplaceOpt1 = 2;$ReplaceOpt2 = 1}
    If($MinimumVersion -eq 2){$ReplaceOpt1 = 1;$ReplaceOpt2 = 2}
    #location of the FF config file
    $file = 'c:\program files\mozilla firefox\mozilla.cfg'
    #load the config file contents into memory for editing
    $mozillaconfig = Get-Content $file
    #the file is set read only, so we turn that off so we can save over it later. The file is in program files, and that's we this script needs admin rights to function.
    set-itemproperty -path 'c:\program files\mozilla firefox\mozilla.cfg' -name isreadonly -value $false
    #this loop runs across each line of the config. the line that sets version.min is edited, other lines are left alone.
    #save the contents of the edited config to the file
    $mozillaconfig | 
    foreach-object {switch -regex ($_){
        ('^lockPref\("security\.tls\.version\.min"\, ' + "$($ReplaceOpt1)\)") {$_ -replace "$ReplaceOpt1","$ReplaceOpt2"}
        default {$_}}} |
        set-content $file
    #and we make the file read only again so it is as secure as it was before we toyed with it
    set-itemproperty -path 'c:\program files\mozilla firefox\mozilla.cfg' -name isreadonly -value $true
}
