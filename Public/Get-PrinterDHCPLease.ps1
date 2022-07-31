<#
.SYNOPSIS
    Search the Fort Leonard Wood printer DHCP scopes for leases.
.DESCRIPTION
    This script searches all or part of the printer IP scopes for leases associated with a MAC or IP address. 
    The script can take multiple addresses as input, separate multiple addresses with commas or use an array variable.
.NOTES
    AUTHOR: O'Ryan R Hedrick
    COMPANY: Ft Leonard Wood Network Enterprise Center
    LAST UPDATE: 22 DEC 2021
    TARGET AUDIENCE: Printer Administrators
.EXAMPLE
    PS C:\WINDOWS\system32> Get-PrinterDHCPLease -ipaddress XXX.XXX.XXX.XXX


    IPAddress       : XXX.XXX.XXX.XXX
    ScopeId         : XXX.XXX.XXX.XXX
    Description     :
    ClientId        : XX-XX-XX-XX-XX-XX
    HostName        : printer.foo.bar.baz.com
    ClientType      : Dhcp
    AddressState    : Active
    DnsRR           : AandPTR
    DnsRegistration : Pending
    LeaseExpiryTime : 5/17/2019 2:09:03 PM
    NapCapable      : False
    NapStatus       : FullAccess
    ProbationEnds   :
    PolicyName      :
    ServerIP        : XXX.XXX.XXX.XXX

    This command searches for the lease associated with the IP address XXX.XXX.XXX.XXX
.EXAMPLE
    PS C:\WINDOWS\system32> Get-PrinterDHCPLease -mac XX-XX-XX-XX-XX-XX -printer


    IPAddress       : XXX.XXX.XXX.XXX
    ScopeId         : XXX.XXX.XXX.XXX
    Description     :
    ClientId        : XX-XX-XX-XX-XX-XX
    HostName        : printer.foo.bar.baz.com
    ClientType      : Dhcp
    AddressState    : ActiveReservation
    DnsRR           : AandPTR
    DnsRegistration : Pending
    LeaseExpiryTime :
    NapCapable      : False
    NapStatus       : FullAccess
    ProbationEnds   :
    PolicyName      :
    ServerIP        : XXX.XXX.XXX.XXX

    This command searches the printer scopes for any leases associated with the MAC XX-XX-XX-XX-XX-XX.
.EXAMPLE
    PS C:\WINDOWS\system32> Get-PrinterDHCPLease -mac XX-XX-XX-XX-XX-XX,XX-XX-XX-XX-XX-XX -printer


    IPAddress       : XXX.XXX.XXX.XXX
    ScopeId         : XXX.XXX.XXX.XXX
    Description     :
    ClientId        : XX-XX-XX-XX-XX-XX
    HostName        : printer.foo.bar.baz.com
    ClientType      : Dhcp
    AddressState    : ActiveReservation
    DnsRR           : AandPTR
    DnsRegistration : Pending
    LeaseExpiryTime :
    NapCapable      : False
    NapStatus       : FullAccess
    ProbationEnds   :
    PolicyName      :
    ServerIP        : XXX.XXX.XXX.XXX





    IPAddress       : XXX.XXX.XXX.XXX
    ScopeId         : XXX.XXX.XXX.XXX
    Description     :
    ClientId        : XX-XX-XX-XX-XX-XX
    HostName        : printer.foo.bar.baz.com
    ClientType      : Dhcp
    AddressState    : Active
    DnsRR           : AandPTR
    DnsRegistration : Pending
    LeaseExpiryTime : 5/17/2019 2:09:03 PM
    NapCapable      : False
    NapStatus       : FullAccess
    ProbationEnds   :
    PolicyName      :
    ServerIP        : XXX.XXX.XXX.XXX

    This command searches for multiple MACs.
.INPUTS
    This script does not accept pipeline input.
.OUTPUTS
    This script outputs objects containing DHCP lease information.
.NOTES
    General notes
#>
function Get-PrinterDHCPLease {
    [CmdletBinding()]
    Param
    (
    # Enter the MAC of the device whose lease you want to retrieve.
    [Parameter(ParameterSetName="MAC",Position=0,ValueFromPipeline=$true)]
    [string[]]
    $MAC,
    # Enter the IP address tied to the lease you want to retrieve.
    [Parameter(ParameterSetName="IPAddress")]
    [string[]]
    $IPAddress,
    # Enter the properties you want to see
    [string[]]
    $Properties = @("ScopeId","IPAddress","ClientID","AddressState","Hostname","ServerIP")
    )

    Begin
    {
        #get the scopes from the printer tools config
        $Config = Get-PrinterToolsConfig
        $scopes = $Config.PrinterIPScopes
        $dhcpserver = $Config.DHCPServers[0]
        #get a count of scopes and create an iterator for use in the progress bar
        $scopesCount = $scopes.count
        $I = 1
    }

    Process
    {
        if($MAC){
            ForEach ($scope in $scopes) {
                $scopeid = $scope.scopeid
                write-verbose "Searching $scopeid"
                ForEach ($address in $MAC){
                    $address = $address.replace(":","-")
                    get-dhcpserverv4lease -scopeid $scope -clientid $address -computername $dhcpserver -ErrorAction SilentlyContinue | 
                    Select-Object $properties
                }
                write-progress -activity "Search DHCP scopes" -status "Progress" -PercentComplete ($I / $scopesCount * 100)
                $I += 1
            }
        }
        if($IPAddress){
            ForEach ($address in $IPAddress){
                write-verbose "Searching for lease associated with IP address $address"
                get-dhcpserverv4lease -ipaddress $address -computername $dhcpserver | 
                Select-Object $properties
            }
        }
    }

    End
    {
    }

}