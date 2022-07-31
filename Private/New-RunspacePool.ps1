<#
.SYNOPSIS
Creates a runspace pool for multithreading scripts.
.DESCRIPTION
This script wraps the runspace factory into a cmdlet for easing use of runspaces in scripts. It emits the runspace object so that it can be used as an argument in other cmdlets.
.NOTES
AUTHOR: O'Ryan Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 08 APR 2022
INTENDED AUDIENCE: Script writers
#>
function New-RunspacePool {
    param(
        [int]$MinimumThreads,
        [int]$MaximumThreads
    )
    $RunspacePool = [runspacefactory]::CreateRunspacePool($MinimumThreads,$MaximumThreads)
    $RunspacePool.Open()
    $RunspacePool
}