<#
.SYNOPSIS
Configure Chrome and Edge to ignore some SSL errors common to printers.
.DESCRIPTION
Both Edge and Chome have some registry settings configured per STIGs that interfere with managing old printers. This function disables those security features. If the features are being set by GPO, you'll need to run this again every time Group Policy is applied.
.NOTES
INTENDED AUDIENCE: Printer administrators
#>
function Disable-BrowserCertCheck {
    [Alias("dbcc")]
    param()
    IF(!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Internet Settings")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Internet Settings" -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Internet Settings" -Name "PreventCertErrorOverrides" -Value "0" -PropertyType DWORD -Force | Out-Null
    }
    ELSE {New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Internet Settings" -Name "PreventCertErrorOverrides" -Value "0" -PropertyType DWORD -Force | Out-Null}
    IF(!(Test-Path "HKLM:\SOFTWARE\Policies\Google\Chrome")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Force | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name "EnableOnlineRevocationChecks" -Value "0" -PropertyType DWORD -Force | Out-Null
    }
    ELSE {New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name "EnableOnlineRevocationChecks" -Value "0" -PropertyType DWORD -Force | Out-Null}
            
        
}
