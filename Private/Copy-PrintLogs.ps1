<#
.SYNOPSIS
Helper function for Update-PrinterLog: copies logs created after the last record date in the database
.DESCRIPTION

.NOTES
AUTHOR: O'Ryan R Hedrick
COMPANY: Ft Leonard Wood Network Enterprise Center
LAST UPDATE: 28 OCT 2021
INTENDED AUDIENCE: Printer administrators
TODO
  * work with files instead of in memory objects, I think the collected logs are too big
#>
Function Copy-PrintLogs {
    [cmdletbinding()]
    param(
        #This string should be set to the last date that appears in the PrinterLog table. Format is yyyy-MM-DD
        [string]$datestring,
        #Name the server who's logs we're collecting.
        [string]$server,
        #Path to a temp folder to save the logs to.
        [Alias("wd")]
        [string]$WorkingDirectory,
        [string]$PrintLogPath
    )
    $UpdateFiles = (Get-ChildItem ("{0}\{1}_EventLogs" -f $printlogpath,$server)).where{((get-logdate -filename $_.name) -gt (get-date $datestring)) -and ((get-logdate -filename $_.name) -lt (get-date).adddays(-1))}
    $OutputFile = new-temporaryfile
    Set-Content -path $OutputFile -value '"TimeCreated","UserName","ComputerName","PrinterName","PrintSize","Pages","Server"'
    Write-Log -Temp -Severity Info -Message "Output file is $($Outputfile.name)"
    Write-Log -Console -Severity Verbose -Message  "Output file is $($Outputfile.name)"
    #$Update = @()
    #Add the header in, because we are going to strip the headers from the individual files
    #$Update += '"TimeCreated","UserName","ComputerName","PrinterName","PrintSize","Pages"'
    Foreach ($File in $UpdateFiles){
        $FilePath = "{0}\{1}_EventLogs\{2}" -f $PrintLogPath,$Server,$File
        Write-Log -Temp -Severity Info -Message "Trying to read $FilePath"
        Write-Log -Console -Severity Verbose -Message  "Trying to read $FilePath"
        if(-not (Test-Path $FilePath)){
            Write-Log -Temp -Severity Error -Message "Error reading audit csv files."
            Throw "Error reading audit csv files."
        }
        $FileContent = Get-Content -Path $FilePath
        Write-Log -Temp -Severity Info -Message "$($FileContent.Count) lines found in file."
        Write-Log -Console -Severity Verbose -Message  "$($FileContent.Count) lines found in file."
        #if the file was empty, we need to skip it because we run into a terminating error
        if($FileContent.Count -eq 0){
            continue
        }
        #Some of the files are wrong, I'm not sure why. If the header is wrong, we need to skip the file
        if ($FileContent[0] -eq '"IsReadOnly","IsFixedSize","IsSynchronized","Keys","Values","SyncRoot","Count"'){
            continue
        }
        #remove the header
        $FileContent = $FileContent[1..($FileContent.Count - 1)]
        #Add the server name to each line of the file
        $OutputFileContents = @()
        Foreach ($line in $FileContent){
            $line = $line + ",""$server"""
            #Add-Content -Path $OutputFile -value $line
            $OutputFileContents += $line
        }

        #add content to the $update variable
        #$Update += $FileContent
        Add-Content -path $OutputFile -value $OutputFileContents
    }
    #return the final output file
    $OutputFile
}
