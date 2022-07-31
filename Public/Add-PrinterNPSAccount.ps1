<#
.SYNOPSIS
Create an AD user account so that MAB/NPS shifts the printer from remediation to the printer vlans.
.DESCRIPTION
An account is created using the printer's MAC, without separating dashes or colons, as the account name.
This account is added to the FLW_NPS_Printers or the FLW_NPS_USARC_Printers group. Most of this function
was lifted from the NID PowerShell script written by Joseph Dively.
.NOTES
AUTHOR: O'Ryan Hedrick
LAST UPDATE: 12 NOV 2021
INTENDED AUDIENCE: Printer administrators
#>
function Add-PrinterNPSAccount {
    [alias("apnps")]
    [cmdletbinding()]
    param(
        #The printer's MAC address. This can be entered with or without dashes.
        $MACAddress,
        [switch]
        $Testing
    )
    $Config = Get-PrinterToolsConfig
    $GroupName = $Config.PrintersMABGroup
    $OUName = "Printers"
    #region setup variables
    #MAC should be stripped of separators
    $MACAddress = $MACAddress.replace("-","").replace(":","")
    #Check if an account already exists, and throw a terminating error if it does so we don't try creating it again.
    #if(Test-PrinterNPSAccount $MACAddress){throw [System.Data.DuplicateNameException]::New("NPS account already exists for $MACAddress.")}
    if(Test-PrinterNPSAccount $MACAddress){
        Write-Error -Category ResourceExists -Message "NPS account already exists for $MACAddress."
        return
    }
    #AD wants some names, so we give it some
    $UserFirstname = $MACAddress
    $UserLastname = $Config.Domain
    $Displayname =  "{0}@{1}" -f $MACAddress,$UserLastname
    #the SAMAccountName is what we think of as the actual user name
    $SAM = $MACAddress
    #UPN includes the domain name
    $UPN = "{0}@{1}" -f $MACAddress,$UserLastname
    $OU = "OU=$OUName" + $Config.PrintersMABOU
    #endregion setup variables
    #region create account
    Write-Verbose ("Creating AD user account named {0}, with the following properties`nSamAccountName {1}`nUserPrincipalName {2}`nGivenName {3}`nSurname {4}`nDescription {5}`nPassword not displayed here`nPath {6}" -f $Displayname,$SAM,$UPN,$UserFirstname,$UserLastname,$Description,$OU)
    #I'm wrapping the user creation/manipulation lines in if statements so I can run with -testing switch enabled to verify the info presented by the write-verbose statements looks right without actually hitting AD
    if(-not $Testing){
        New-ADUser -Name $Displayname -DisplayName $Displayname -SamAccountName $SAM -Office "Office"  -UserPrincipalName $UPN -GivenName $UserFirstname -Surname $UserLastname -Description $Description -AccountPassword (ConvertTo-SecureString $Config.NPSAccountPW -AsPlainText -Force) -Enabled $true -Path $OU -ChangePasswordAtLogon $false -PasswordNeverExpires $true -AllowReversiblePasswordEncryption $false -SmartcardLogonRequired $true -server $Config.DC
        if(-not $?){
            Throw "Error occured while creating the AD user account."
        }
    }
    #Add Group Membership
    if ( -not $Testing){
    Add-ADGroupMember -Identity $GroupName -Members $MACAddress -server $Config.DC
    }
    #endregion create account
}
