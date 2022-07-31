<#
.SYNOPSIS
Test whether a given MAC has an AD account.
.DESCRIPTION
Given a MAC, this function strips any dashes or colons and then checks if that account
exists in AD, returning True or False.

If provided the Members switch, if the account exists we check if it is in either of the 
NPS printer groups.
AUTHOR: O'Ryan Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 12 NOV 2021
INTENDED AUDIENCE: Printer administrators
#>
function Test-PrinterNPSAccount {
    [alias("tpnps")]
    param(
        $MACAddress,
        [switch]
        $Members
    )
    $MACAddress = $MACAddress.replace("-","").replace(":","")
    try{
        Write-Verbose "Search for the account"
        $Account = Get-ADUser $MACAddress -properties memberof
    } catch {
        Write-Verbose "Account not found"
        $false
        return
    }
    if(-not $Members){
        Write-Verbose "Account found"
        $true
    } else {
        Write-Verbose "Account found, checking group memberships"
        $Account.memberof -contains $Config.PrintersMABGroup
    }
}
