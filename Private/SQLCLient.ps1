<#
.SYNOPSIS
Opens a connection to SQL server.
.DESCRIPTION
Wraps around existing methods and objects in .NET for easier use in Powershell.
.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 
INTENDED AUDIENCE: script writers
#>
function Open-SQLConnection {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ComputerName,
        [Parameter()]
        [string]
        $Database,
        [Parameter()]
        [string]
        $IntegratedSecurity = 'True'
    )
    $connection = new-object System.Data.SqlClient.SqlConnection
    $connection.connectionstring = "Server=$computername;DataBase=$database;Integrated Security=$integratedsecurity"
    $connection.open()
    $connection
}
<#
.SYNOPSIS
Closes a connection to SQL server.
.DESCRIPTION
Wraps around existing methods and objects in .NET for easier use in Powershell.
.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 
INTENDED AUDIENCE: script writers
#>
function Close-SQLConnection {
    param(
        [Parameter(Mandatory=$true)]
        [System.Data.SqlClient.SqlConnection]
        $connection
    )
    $connection.Close()
}
<#
.SYNOPSIS
Creates a System.Data.SqlClient.SqlCommand object.
.DESCRIPTION
Wraps around existing methods and objects in .NET for easier use in Powershell.
.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 
INTENDED AUDIENCE: script writers
#>
function New-SQLCommand {
    param(
        #SQL command to run against the database
        [Parameter(Mandatory=$true)]
        [string]
        $CommandText,
        #The type of command being run.
        [system.data.commandtype]
        $CommandType,
        #An open connection to a database.
        [Parameter(Mandatory=$true)]
        [System.Data.SqlClient.SqlConnection]
        $Connection,
        #A hash table of parameters to add to the command
        [hashtable]
        $Parameters
    )
    $command = new-object System.Data.SqlClient.SqlCommand
    if($CommandType){$command.CommandType = $CommandType}
    $command.Connection = $Connection
    $command.CommandText = $CommandText
    If($parameters){
        foreach ($key in $parameters.keys){
            [void]$command.Parameters.AddWithValue("@$key",$parameters[$key])
        }
    }
    $command
}

<#
.SYNOPSIS
Creates a System.Data.DataSet object and fills it with data from the SQL server.
.DESCRIPTION
Wraps around existing methods and objects in .NET for easier use in Powershell.
.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 
INTENDED AUDIENCE: script writers
#>
function Import-SQLData {
    param(
        $command
    )
    $da = new-object System.Data.SqlClient.SqlDataAdapter
    $ds = new-object System.Data.DataSet
    $da.SelectCommand = $command
    [void]$da.fill($ds)
    $ds
}