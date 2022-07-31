function Add-ScriptToRunspacePool {
    param(
        [scriptblock]
        $ScriptBlock,
        [System.Management.Automation.Runspaces.RunspacePool]
        $RunspacePool,
        [hashtable]
        $ArgumentHash
    )
    $PowerShell = [powershell]::Create()
    $PowerShell.RunspacePool = $RunspacePool
    $PowerShell.AddScript($ScriptBlock) | out-null
    foreach ($key in $ArgumentHash.Keys) {
        $PowerShell.AddParameter($key,$ArgumentHash.$key) | out-null
    }
    $PowerShell
}