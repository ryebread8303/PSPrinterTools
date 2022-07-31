<#
.SYNOPSIS
This script collects data from print and dhcp servers so that everything can be stored in an Access database for easier querying.
.DESCRIPTION
Function gathers data from each printer server and printer IP scope listed in the FLWPrinterTools config, and also grabs NPS accounts in the printers NPS group listed in the FLWPrinterTools config. This data is saved locally to the users machine so that it can be uploaded to SharePoint via a set of MS Access macros.

The script uses PSJobs to gather data concurrently, which dramatically reduces the time it takes to complete.
.NOTES
AUTHOR: O'Ryan Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 22 APR 2022
INTENDED AUDIENCE: Printer administrators in charge of PrinterDB
CHANGE LOG:
  # 20220422: Switched from PSJobs to runspaces for better performance.
  # 20211027: Adjusted to use FLWPrinterTools 1.5 shared config file.
  # 20210630: Incorporated into FLWPrinterTools module
  # 20210325: Modified to work with the sharepoint version of PrinterDB.
  # 20200424: Collect list of MACs enrolled in NPS from AD.
  # 20200417: Uses jobs to run queries in parallel.
  # 20200415: Uses temp files during collection and copies to the backup folder 
  #           and the PrinterDB folder.
  # 20200407: Added progress bars.
  # 20200406: Refactored for clarity
  # 20200403: Changed location of csv files to work with new PrinterDB
  # 20200212: First written
#>
function Import-PrintServerData {
    [cmdletbinding()]
    param()
    #region getting ready
    Write-Log -Temp -Severity Info -Message "Getting Printer Tools configuration."
    $Config = Get-PrinterToolsConfig
    Write-Log -Temp -Severity Info -Message "Got Printer Tools configuration."
    #I'm changing the ErrorActionPreference so that the script doesn't keep on and clobber a bunch of things after encountering an error
    $ErrorActionPreference = "Stop"
    Write-Log -Temp -Severity Info -Message "Error action preference is $ErrorActionPreference."
    #If the user passes the -Verbose argument, we want to set the LogLevel to Verbose.
    #I need to do this because I'm using Write-Log for all logging, console and file based.
    if($VerbosePreference = "Continue"){$LogLevel = [LogLevel]"Verbose"}
    #I want a timestamp to add to filenames
    $timestamp = get-date -uformat %Y%m%d%H%M
    #putting all the queries in one object to help organize this script. I'm passing these script blocks to the New-Query function.
    Write-Log -Temp -Severity Info -Message "Declared server queries."
    $ServerQuery = [pscustomobject]@{
        Spooler = {
            param([string]$computername)
            get-printer -computername $computername |
            Select-Object computername,name,sharename,drivername,location,portname}
        Port = {
            param([string]$computername)
            get-printerport -computername $computername |
            where-object{$_.description -eq "Standard TCP/IP Port"} |
            Select-Object computername,name,printerhostaddress}
        Reservation = {
            param([string]$computername,[string]$scopeid)
            get-dhcpserverv4reservation -computername $computername -scopeid $scopeid}
    }
    function Get-MACFromADNPSAccount {
        param([string[]]$DistinguishedName)
        $result = @()
        Foreach ($name in $DistinguishedName){
            $name -match '^CN=([0-9a-f]{12})@nanw' | out-null
            $result += [pscustomobject]@{MAC = ($matches[1] -split '([a-f0-9]{2})' -ne '' -join '-')}
        }
        $result
    }

    function New-Query {
        param(
            [string[]]
            $Server,
            [validateset("Reservation","Spooler","Port")]
            $QueryType,
            [System.Management.Automation.Runspaces.RunspacePool]
            $RunspacePool
        )
        Foreach($s in $server) {
            Write-Log -Console -severity Verbose -message "Starting shell for querying $Server for $QueryType"
            Write-Log -Temp -severity Info -message "Starting shell for querying $Server for $QueryType"
            Switch($QueryType){
                "Spooler" {$Shell = Add-ScriptToRunspacePool -scriptblock $ServerQuery.Spooler -runspacepool $RunspacePool -ArgumentHash @{computername=$s}}
                "Port" {$Shell = Add-ScriptToRunspacePool -scriptblock $ServerQuery.Port -runspacepool $RunspacePool -ArgumentHash @{computername=$s}}
                "Reservation" { 
                    foreach ($scope in $Config.PrinterIPScopes){
                        $Shell = Add-ScriptToRunspacePool -scriptblock $ServerQuery.Reservation -runspacepool $RunspacePool -ArgumentHash @{computername=$Config.DHCPServers[0];scopeid=$s}
                    }
                }
            }
            [pscustomobject]@{Shell=$Shell;Type=$QueryType}
        }
    }
    #create temp files
    $spoolertemp = New-TemporaryFile
    $porttemp = New-TemporaryFile
    $reservationtemp = New-TemporaryFile
    $npstemp = New-TemporaryFile
    Write-Log -Temp -Severity Info -Message "Created temp files $spoolertemp,$porttemp,$reservationtemp, and $npstemp."
    Write-Log -Temp -Severity Info -Message "Attempting to create a runspacepool."
    #endregion getting ready
    #region queries
    #I've switched to using a runspace pool instead of PSJobs due to the number of queries.
    #With 20 queries starting, the extra setup time needed by PSJobs is pretty significant.
    #Sadly, runspaces are a little more complicated. The script blocks are declared in the getting ready region, see the ServerQuery variable.
    #RSPool is the runspace pool, and it manages the parallel execution.
    #the Queries variable is a List object that is organizing the actual script objects, their execution, and the results obtained.
    #First, a shell is started using the New-Query function. That shell is then asynchronously invoked, and the object representing that invocation is stored as the Job property.
    #Once all the script invocations are complete, the results are stored in the Result property.
    $RSPool = new-runspacepool -MinimumThreads 5 -MaximumThreads 10
    Write-Log -Temp -Severity Info -Message "Attempting to create query shells."
    #the try...catch block is to catch errors and end the script. Write-Log helps dump the log to a log file so it can be examined later
    try {
        #Queries is a List, which is like an array but has an Add() method that lets you add objects without PowerShell recreating the whole array for each object added.
        $Queries = new-object system.collections.generic.list[pscustomobject]
        #Each query gets added to the List, so the Queries object holds all 20 queries. This is fine, since the process for running each query and getting the results is the same for all of them.
        $Config.PrintServers | ForEach-Object{$Queries.Add((New-Query -Server $_ -QueryType "Spooler" -RunspacePool $RSPool))}
        $Config.PrintServers | ForEach-Object{$Queries.Add((New-Query -Server $_ -QueryType "Port"))}
        $Config.PrinterIPScopes | ForEach-Object{$Queries.Add((New-Query -Server $_ -QueryType "Reservation"))}
        Write-Log -Temp -Severity Info -Message "$($Queries.count) queries queued."
    } catch {
        Write-Log -Temp -Severity Error -Message "Failed to create query shells."
        Throw "Error creating query shells.`n$PSItem"
    }
    Write-Log -Temp -Severity Info -Message "Invoking the shells."
    Foreach ($Query in $Queries) {
        #this Write-Log statement was meant to list the actual commands being run, but it just returns an object type. I'll try and fix that sometime.
        #Write-Log -Temp -Severity Info -Message "Invoking $($Query.Shell.commands)"
        #BeginInvoke() starts the queries asynchronously, so that they can run at the same time.
        #The runspace pool manages the actually running of these invocations.
        $Query | Add-member -membertype noteproperty -name job -value $Query.Shell.BeginInvoke()
    }
    Write-Log -Temp -Severity Info -Message "Waiting for jobs to finish."
    #Wait for all jobs to finish
    [bool]$jobsRunning = $true
    while ($jobsRunning){
        start-sleep 60
        $jobsRunning = $Queries.Job.IsCompleted -contains $false
        $count = ($Queries.Job | where-object {$_.IsCompleted -eq $false}).count
        Write-Log -Temp -Severity Info -Message "$count query jobs are still running."
        Write-Log -Console -Severity Verbose -Message "$count Query Jobs are still running"
    }
    #Get list of Printer NPS accounts
    #I'm not running this in parallel because it doesn't take very long
    Write-Log -Temp -Severity Info -Message "Getting NPS accounts."
    Write-Log -Console -Severity Verbose -Message "Getting NPS accounts."
    $printerADaccts = get-adgroup $Config.PrintersMABGroup -Properties members | Select-Object -ExpandProperty members

    #Collect results
    Write-Log -Temp -Severity Info -Message "Collecting data from jobs."
    Write-Log -Console -Severity Verbose -Message "Receiving data from jobs."
    Foreach ($Query in $Queries) {
        #The EndInvoke() method takes the Job object created by the BeginInvoke() method as its argument.
        #It should return the results of the command being run, which should be an array of objects.
        $Query | Add-Member -membertype noteproperty -name Result -value $Query.Shell.EndInvoke($Query.Job)
        #I'm having some trouble getting the results into files, so I'm adding logs to trace where my results become null.
        #The Message is using the string formatter because the typical PowerShell string interpolation would be messy.
        Write-Log -Temp -Severity Info -Message ("Query resulted in object of type {0}, with {1} records." -f $Query.Result.gettype(),$Query.Result.count)
    }

    $NPSMAC = Get-MACFromADNPSAccount $printerADaccts
    #endregion queries
    #region output
    #Export the results as csv to temp files. The select-object statements remove properties of the jobs from the results.
    Write-Log -Temp -Severity Info -Message "Exporting collected data to temp files."
    Write-Log -Console -Severity Verbose -Message "Exporting collected data to csv files."
    Foreach ($Query in $Queries){
        Write-Log -Temp -Severity Info -Message "Adding $($Query.Result.count) records to $($Query.Type) report."
        Switch ($Query.Type){
            "Spooler" {
                #adding this write log for debugging purposes; the CSVs have been coming out empty
                Write-Log -Console -Severity Verbose -Message ("Sample record being added to file: {0}" -f $Query[0].Result[0])
                $Query.Result | export-csv $spoolertemp -notypeinformation -Append
                }
            "Port" {
                $Query.Result | export-csv $porttemp -notypeinformation -Append
            }
            "Reservation" {
                $Query.Result | export-csv $reservationtemp -notypeinformation -Append
            }
        }
    }
    Write-Log -Temp -Severity Info -Message "Adding $($NPSMAC.count) records to NPS report."
    $NPSMAC | export-csv $NPStemp -notypeinformation
    #Copy the result files to their destinations
    Write-Log -Console -Severity Verbose -Message "Copying csv files to their destinations."
    Copy-item $spoolertemp $PrinterDBDataFolder\spoolers$timestamp.csv 
    Copy-Item $spoolertemp $PrinterDBDataFolder\Spoolers.csv -force
    Write-Log -Temp -Severity Info -Message "Copied spooler file to $PrinterDBDataFolder."
    Copy-item $porttemp $PrinterDBDataFolder\ports$timestamp.csv
    Copy-Item $porttemp $PrinterDBDataFolder\Ports.csv -force
    Write-Log -Temp -Severity Info -Message "Copied port file to $PrinterDBDataFolder."
    Copy-Item $reservationtemp $PrinterDBDataFolder\reservations$timestamp.csv
    Copy-Item $reservationtemp $PrinterDBDataFolder\Reservations.csv -force
    Write-Log -Temp -Severity Info -Message "Copied reservation file to $PrinterDBDataFolder."
    Copy-Item $npstemp $PrinterDBDataFolder\NPS$timestamp.csv
    Copy-Item $npstemp $PrinterDBDataFolder\NPS.csv -force
    Write-Log -Temp -Severity Info -Message "Copied NPS file to $PrinterDBDataFolder."
    #endregion output
    #region cleanup
    #remove temp files
    Write-Log -Console -Severity Verbose -Message "Removing temp files."
    remove-item $porttemp
    remove-item $spoolertemp
    remove-item $reservationtemp
    remove-item $npstemp 
    Write-Log -Temp -Severity Info -Message "Removed temp files."
    #Notify user that collection is complete
    Write-Host "Data collection complete."
    #Write-Log -Temp -Severity Verbose -Message "Disposing of Job objects."
    #$Queries.Job.Dispose()
    Write-Log -Temp -Severity Verbose -Message "Disposing of Shell objects."
    $Queries.Shell.Dispose()
    Write-Log -Temp -Severity Verbose -Message "Disposing of runspaces."
    $RSPool.Dispose()
    Write-Log -Temp -Severity Info -Message "Disposed of runspaces, shells and jobs."
    #endregion cleanup
}
