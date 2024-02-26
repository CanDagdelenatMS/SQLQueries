param (
    [string[]]$computernames= "localhost",
    [boolean]$QueryUserRights= $false, #by default queries User Rights Assignment
    [boolean]$QueryCompInfo= $true,    #by default queries Computer Info such as CPU info, disk sizes, cluster info etc.
    [boolean]$TestWinRMAccess= $false   #by default tests WinRM network access
    )

Write-Host "******************************Script started******************************" -ForegroundColor Gray
#region preparefiles
$UserRightsFile= "UserRights.JSON"
$CompInfoCSVFile= "CompInfo.csv"

If (test-path .\$UserRightsFile) {
if (Test-Path .\previous_$UserRightsFile) {Remove-Item .\previous_$UserRightsFile}
Rename-Item -LiteralPath .\$UserRightsFile -NewName "previous_$UserRightsFile"
}

If (test-path .\$CompInfoCSVFile) {
if (Test-Path .\previous_$CompInfoCSVFile) {Remove-Item .\previous_$CompInfoCSVFile}
Rename-Item -LiteralPath .\$CompInfoCSVFile -NewName "previous_$CompInfoCSVFile"
}

#endregion
#region Winrm Check
if ($TestWinRMAccess)
{
    Write-Host "Testing WinRM network access:" -ForegroundColor Yellow
    $testresult= $true
    foreach ($comp in $computernames)
        {
        if (-not (Test-NetConnection -CommonTCPPort WINRM -ComputerName $comp).TcpTestSucceeded) 
            {
            Write-Host "`tNo WinRM network access to remote computer: $comp" -ForegroundColor Red
            $TestResult= $false}
        else {Write-Host "`tSuccesful WinRM network access to remote computer: $comp" -ForegroundColor Green}
        }
}
else
{ $testresult = $true
}

#endregion

if (-not $testresult) {
Write-Host 'WinRM tests failed. Ensure Computernames are correct and are reachable on 5985 port. Script will exit now!' -ForegroundColor Red
throw 'WinRM tests failed.'

}

foreach ($comp in $computernames)

{
 #region Machine info queries with output to CSV File
 if($QueryCompInfo)
    {

    Write-Host "Working on $comp machine info, please wait..." -ForegroundColor Yellow -NoNewline

    

 

    $script =

        {

        Import-Module SQLPS

 

        #Get info for computer resources: CPU, Memory, Disk

            $result= Get-WmiObject -ComputerName localhost win32_processor | select @{Label= 'ComputerName'; Expression={$env:COMPUTERNAME}}, @{Label= 'CPUName'; Expression={$_.Name}}, NumberOfCores, NumberOfEnabledCore, NumberOfLogicalProcessors

 

                                if   ($result.count)

                

                                            {$NoOfSockets= $result.count

               

                                            $result= $result[0]

               

                                            $result | Add-Member -Name 'NoOfSockets' -MemberType NoteProperty -Value $NoOfSockets }

                

                                else {$result | Add-Member -Name 'NoOfSockets' -MemberType NoteProperty -Value '1' }

            $memorysize= (Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB

            $result | Add-Member -Name 'MemorySize' -MemberType NoteProperty -Value $memorysize

            $result | Add-Member -Name 'DiskTotalSize' -MemberType NoteProperty -Value ""

            $result | Add-Member -Name 'DiskSizeRemaining' -MemberType NoteProperty -Value ""

            get-volume | select DriveLetter, @{Label='Size'; expression={($_.Size/1GB).ToString('F2')}}, @{Label='SizeRemaining'; expression={($_.SizeRemaining/1GB).ToString('F2')}} | foreach {

                        if ($_.DriveLetter) {

                                $result.DiskTotalSize += "$($_.DriveLetter) = $($_.Size); "

                                $result.DiskSizeRemaining += "$($_.DriveLetter) = $($_.SizeRemaining); "

                                    }

                            }

            $result.DiskTotalSize= $result.DiskTotalSize -replace ".{2}$"

            $result.DiskSizeRemaining= $result.DiskSizeRemaining -replace ".{2}$"

 

        #Get info for language, timezone

            $lang= (Get-Culture | select Name).name

            $timezone= (Get-TimeZone | select DisplayName).DisplayName

            $result | Add-Member -Name 'Language' -MemberType NoteProperty -Value "$lang"

            $result | Add-Member -Name 'TimeZone' -MemberType NoteProperty -Value "$timezone"

 

        #Get info for Make, Model

            $systeminfo= Get-CimInstance -ClassName Win32_ComputerSystem | select Manufacturer, SystemFamily, SystemSKUNumber

            $result | Add-Member -Name 'Manufacturer' -MemberType NoteProperty -Value "$($systeminfo.Manufacturer)"

            $result | Add-Member -Name 'SystemFamily' -MemberType NoteProperty -Value "$($systeminfo.SystemFamily)"

            $result | Add-Member -Name 'SystemSKUNumber' -MemberType NoteProperty -Value "$($systeminfo.SystemSKUNumber)"

   

        #Get info about latest updates   

            $updateinfo=((Get-HotFix | ?{$_.InstalledOn -notlike $null } | Sort-Object -Property InstalledOn )[-1..-3]).HotFixID -join ";"

            $result | Add-Member -Name 'Last3InstalledUpdates' -MemberType NoteProperty -Value "$updateinfo"

 

        #Get info about mount points

            $mountpts= Get-CimInstance Win32_MountPoint | where {$_.Directory.Name -match '.:\\.+'}

            $result | Add-Member -Name 'MountPoints' -MemberType NoteProperty -Value ($mountpts.directory.name -join ";" -replace('.:\\',''))

            $result | Add-Member -Name 'MountPointTotalSize' -MemberType NoteProperty -Value ""

            $result | Add-Member -Name 'MountPointSizeRemaining' -MemberType NoteProperty -Value ""

            $mountpts | foreach {

                    $mpt_volinfo= Get-Volume -UniqueId "$($_.Volume.DeviceID)" | select @{Label='Size'; expression={($_.Size/1GB).ToString('F2')}}, @{Label='SizeRemaining'; expression={($_.SizeRemaining/1GB).ToString('F2')}}

                    $result.MountPointTotalSize += "$($_.directory.name -replace('.:\\','')) = $($mpt_volinfo.Size); "

                    $result.MountPointSizeRemaining += "$($_.directory.name -replace('.:\\','')) = $($mpt_volinfo.SizeRemaining); "

                    }

            $result.MountPointSizeRemaining = $result.MountPointSizeRemaining -replace ".{2}$" #removes the last 2 characters which are: '; '

            $result.MountPointTotalSize = $result.MountPointTotalSize -replace ".{2}$"

 

        #Get info about "SQL Server" and "SQL Server Agent" service accounts

         $sqlserveraccount = Get-CimInstance Win32_Service | ?{$_.Name -clike '*MSSQL*' -and  $_.Name -cnotlike '*MSSQLLaunchpad*'}

         $sqlagentaccount = Get-CimInstance Win32_Service  | ?{$_.Name -clike '*SQLAgent*' -or  $_.Name -clike '*SQLSERVERAGENT*'}

         $result | Add-Member -Name "SQLServer_SrvAccount" -MemberType NoteProperty -Value "$($sqlserveraccount.startname)"

         $result | Add-Member -Name "SQLAgent_SrvAccount" -MemberType NoteProperty -Value "$($sqlagentaccount.startname)"

 

         #Get info about cluster quorum & cluster resources & Instance & Database Availability Group

           $qinfo= Get-ClusterQuorum

           $cresources= Get-ClusterResource  | select name, ownernode, ResourceType

           $result | Add-Member -Name 'ClusterName' -MemberType NoteProperty -Value "$($qinfo.Cluster)"

           $result | Add-Member -Name 'QuorumResource' -MemberType NoteProperty -Value "$($qinfo.QuorumResource)"

           $result | Add-Member -Name 'QuorumType' -MemberType NoteProperty -Value "$($qinfo.QuorumType)"

           $instancename= (get-service  | where-object {$_.Name -clike "*MSSQL*" -and $_.Name -cnotlike "*MSSQLLaunchpad*" -and $_.DisplayName -cnotlike "*SQL Full-text Filter*"} ).DisplayName -replace('SQL Server \(','') -replace('\)','') 

           if ($instancename -like 'MSSQLServer') { $instancename= 'DEFAULT'}

           $result | Add-Member -Name 'SQL_InstanceName' -MemberType NoteProperty -Value "$instancename"

           $aginfo= $cresources | where resourcetype -eq "SQL Server Availability Group" | select name, ownernode

           $result | Add-Member -Name "SQLAvailabilityGroupName" -MemberType NoteProperty -Value "$($aginfo.Name)"

           $result | Add-Member -Name "SQLAvailabilityGroupOwner" -MemberType NoteProperty -Value "$($aginfo.ownernode)"

           $netnameinfo= $cresources | where resourcetype -eq "Network Name" | select name, ownernode

           $Sqlinfo=$null

           $Sqlinfo= (Get-ClusterResource | where resourcetype -like "SQL Server"  | Get-clusterparameter -Name VirtualServerName).Value

           $result | Add-Member -Name "NetworkName" -MemberType NoteProperty -Value "$($netnameinfo.Name)"

           $result | Add-Member -Name "NetworkNameOwner" -MemberType NoteProperty -Value "$($netnameinfo.ownernode)"

           $result | Add-Member -Name "SQLFailoverClusterName" -MemberType NoteProperty -Value "$Sqlinfo"

           $ownerNode=$null

           $ownerNode=(Get-ClusterResource | where resourcetype -like "SQL Server").OwnerNode

           $result | Add-Member -Name "SQLOwnerNode" -MemberType NoteProperty -Value "$ownerNode"

      

           if ($aginfo -and ($env:COMPUTERNAME -eq $ownerNode)) {

     

                            

                     $x=Get-ChildItem "SQLSERVER:\SQL\$sqlinfo\$instancename\AvailabilityGroups"

      

                        $DAGDBNames= $x.AvailabilityDatabases.name -join ";"

                        $DAGDBReplicas= $x.AvailabilityReplicas.Name -join ";"

                     $result | Add-Member -Name 'DAGDBNames' -MemberType NoteProperty -Value "$DAGDBNames"

                     $result | Add-Member -Name 'DAGDBReplicas' -MemberType NoteProperty -Value "$DAGDBReplicas"

 

                    }

            else {

                    $result | Add-Member -Name 'DAGDBNames' -MemberType NoteProperty -Value "$null"

                    $result | Add-Member -Name 'DAGDBReplicas' -MemberType NoteProperty -Value "$null"

                    }

   

        #Get info about local admins

           $localadmins=  (Get-LocalGroupMember "Administrators" ) -join ";"

           $result | Add-Member -Name 'LocalAdminUsers' -MemberType NoteProperty -Value "$localadmins"

  

        #Get info about ODBC DSNs

            $ODBCsources = Get-OdbcDsn | where {$_.DriverName -notlike 'SQL Server*' -and $_.DsnType -eq 'System'}
            
            $result | Add-Member -Name "ODBCSources" -MemberType NoteProperty -Value ""
 

            foreach ($source in $ODBCsources) {
             

                    $result.ODBCSources+=  "$($source.Name); "

                   

                    }

        $result

 

         }

    Invoke-Command -ComputerName $comp -ScriptBlock $script | Export-Csv .\$CompInfoCSVFile -NoTypeInformation -Append
    Write-Host "Done!" -ForegroundColor Yellow

    }

    

   

    #endregion


    #region User Rights Assignment with output to JSON file
    if ($QueryUserRights)
    {
    Write-Host "Working on $comp user rights assignment, please wait..." -ForegroundColor Yellow -NoNewline


    #Get info about user rights assignment

    $script=

            {

                    if (Test-Path c:\tempfolder4clusters -ErrorAction SilentlyContinue) {

                Get-ChildItem c:\tempfolder4clusters | Remove-Item -Recurse -Force | Out-Null

                }

                    else { New-Item -Name tempfolder4clusters -Path c:\ -ItemType Directory | Out-Null }

            secedit /export /cfg c:\tempfolder4clusters\cfg.txt /areas USER_RIGHTS /log c:\tempfolder4clusters\log.txt  | Out-Null

 

            $rights= Get-Content c:\tempfolder4clusters\cfg.txt

            $totalrights= New-Object PSCustomObject

            $totalrights | Add-Member -Name 'ComputerName' -Value "$($env:COMPUTERNAME)" -MemberType NoteProperty

             foreach ($right in $rights[3..($rights.Count -4)] ) { #first few lines and last few lines should be ignored

                    $currentright= ($right -split " = ")[0]

                    $currentusers= ($right -split " = ")[1] -replace("\*",'') -split ","

                    $translatedusers= ''

                            foreach ($user in $currentusers) {

                                    if ($user -like "S-1-5*") {

                                            $SID = New-Object System.Security.Principal.SecurityIdentifier("$user")

                                            $translatedusers += "$($SID.Translate([System.Security.Principal.NTAccount]));" }

                                    }

                    $totalrights | Add-Member -Name $currentright -MemberType NoteProperty -Value $translatedusers

                    }

            $totalrights

            }

 

     $JSON= Invoke-Command -ComputerName $comp -ScriptBlock $script | ConvertTo-Json 
     Out-File -InputObject $JSON  -FilePath .\$UserRightsFile
     Write-Host "Done!`n" -ForegroundColor Yellow
    }

    #endregion

    

 

}

 

Write-Host "******************************Script ended******************************" -ForegroundColor Gray