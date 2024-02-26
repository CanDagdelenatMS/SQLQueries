$findings= Import-Csv .\CompInfo.csv
foreach ($finding in $findings) {
$InsertQuery= @"
INSERT INTO Findings (ComputerName, CPUName, NumberOfCores, NumberOfEnabledCore, NumberOfLogicalProcessors,NoOfSockets, MemorySize, DiskTotalSize, DiskSizeRemaining, Language, 
TimeZone, Manufacturer, SystemFamily, SystemSKUNumber, Last3InstalledUpdates, MountPoints, MountPointTotalSize, MountPointSizeRemaining, SQLServer_SrvAccount, 
SQLAgent_SrvAccount, ClusterName, QuorumResource, QuorumType, SQLClusterName,SQLClusterOwnerNode, SQL_InstanceName, SQLAvailabilityGroupName, SQLAvailabilityGroupOwner, NetworkName, NetworkNameOwner, 
DAGDBNames, DAGDBReplicas, ODBCSources,LocalAdminUsers)
VALUES (`'$($finding.ComputerName)`', `'$($finding.CPUName)`', `'$($finding.NumberOfCores)`', `'$($finding.NumberOfEnabledCore)`', `'$($finding.NumberOfLogicalProcessors)`',
  `'$($finding.NoOfSockets)`',`'$($finding.MemorySize)`', `'$($finding.DiskTotalSize)`', `'$($finding.DiskSizeRemaining)`', `'$($finding.Language)`', `'$($finding.TimeZone)`',
   `'$($finding.Manufacturer)`', `'$($finding.SystemFamily)`', `'$($finding.SystemSKUNumber)`', `'$($finding.Last3InstalledUpdates)`', `'$($finding.MountPoints)`',
    `'$($finding.MountPointTotalSize)`', `'$($finding.MountPointSizeRemaining)`', `'$($finding.SQLServer_SrvAccount)`', `'$($finding.SQLAgent_SrvAccount)`',
     `'$($finding.ClusterName)`', `'$($finding.QuorumResource)`', `'$($finding.QuorumType)`',`'$($finding.SQLFailoverClusterName)`',`'$($finding.SQLOwnerNode)`',
      `'$($finding.SQL_InstanceName)`', `'$($finding.SQLAvailabilityGroupName)`',
      `'$($finding.SQLAvailabilityGroupOwner)`', `'$($finding.NetworkName)`', `'$($finding.NetworkNameOwner)`', `'$($finding.DAGDBNames)`', `'$($finding.DAGDBReplicas)`',
      `'$($finding.ODBCSources)`',  `'$($finding.LocalAdminUsers)`')
"@
$Instancename= 'node1'
$dbname= 'tester'
Invoke-Sqlcmd -ServerInstance $Instancename -Database $dbname -Query $InsertQuery
}
