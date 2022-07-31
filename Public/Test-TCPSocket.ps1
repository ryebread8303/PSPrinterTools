<#
.SYNOPSIS
Quick checker if a TCP socket on a given host is reachable.
.DESCRIPTION
Uses the .NET System.Net.Sockets.TCPClient class to create a connection. If we receive an error we assume that socket is not reachable.
.NOTES
AUTHOR: O'Ryan Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 21 APR 2022
INTENDED AUDIENCE: Script writers
#>
function Test-TCPSocket {
    param(
        $HostName,
        $PortNumber
    )
    try{
        $OriginalErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Stop"
        $TCPClient = new-object System.Net.Sockets.TCPClient($HostName,$PortNumber)
    } catch {
        $false
        return
    } finally {
        $ErrorActionPreference = $OriginalErrorActionPreference
        if ($TCPClient) {$TCPClient.dispose()}
    }
    $true
}