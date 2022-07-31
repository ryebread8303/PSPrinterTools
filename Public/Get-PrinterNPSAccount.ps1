<#
.SYNOPSIS
Fetch a printer's NPS account from AD
.DESCRIPTION

.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 21 APR 2022
INTENDED AUDIENCE: Printer administrators
#>
function Get-PrinterNPSAccount{
    [cmdletbinding()]
    param(
        $MACAddress
    )
    $MACAddress = $MACAddress.replace("-","").replace(":","")
    $NPSAccount = Get-ADUser $MACAddress -properties memberof #| Select-Object SamAccountName,Enabled,memberof,DistinguishedName,lastlogondate,whencreated,description
    $NPSAccount.psobject.typenames.Insert(0,"Printertools.NPSAccount")
    $NPSAccount
}