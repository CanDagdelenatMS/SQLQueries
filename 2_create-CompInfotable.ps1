$createquery= @”
   IF EXISTS (SELECT 1 FROM SYS.objects WHERE name ='Findings')
   DROP TABLE dbo.Findings

    CREATE TABLE [dbo].[Findings](
	[ComputerName] [varchar](500) NULL,
	[CPUName] [varchar](500) NULL,
	[NumberOfCores] [varchar](500) NULL,
	[NumberOfEnabledCore] [varchar](500) NULL,
	[NumberOfLogicalProcessors] [varchar](500) NULL,
	[NoOfSockets] [varchar](100) NULL,
	[MemorySize] [varchar](500) NULL,
	[DiskTotalSize] [varchar](500) NULL,
	[DiskSizeRemaining] [varchar](500) NULL,
	[Language] [varchar](500) NULL,
	[TimeZone] [varchar](500) NULL,
	[Manufacturer] [varchar](500) NULL,
	[SystemFamily] [varchar](500) NULL,
	[SystemSKUNumber] [varchar](500) NULL,
	[Last3InstalledUpdates] [varchar](500) NULL,
	[MountPoints] [varchar](1000) NULL,
	[MountPointTotalSize] [varchar](1000) NULL,
	[MountPointSizeRemaining] [varchar](1000) NULL,
	[SQLServer_SrvAccount] [varchar](500) NULL,
	[SQLAgent_SrvAccount] [varchar](500) NULL,
	[ClusterName] [varchar](500) NULL,
	[QuorumResource] [varchar](500) NULL,
	[QuorumType] [varchar](500) NULL,
	[SQLClusterName] [varchar](500) NULL,
	[SQLClusterOwnerNode] [varchar](500) NULL,
	[SQL_InstanceName] [varchar](500) NULL,
	[SQLAvailabilityGroupName] [varchar](500) NULL,
	[SQLAvailabilityGroupOwner] [varchar](500) NULL,
	[NetworkName] [varchar](500) NULL,
	[NetworkNameOwner] [varchar](500) NULL,
	[DAGDBNames] [nvarchar](max) NULL,
	[DAGDBReplicas] [varchar](500) NULL,
	[ODBCSources] [varchar](500) NULL,
    [LocalAdminUsers] [varchar](500) NULL,
	[LogDate] [smalldatetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[Findings] ADD  CONSTRAINT [DF__Findings__LogDat__098BD816]  DEFAULT (getdate()) FOR [LogDate]
GO
"@

$Instancename= 'node1'
$dbname= 'tester'
Invoke-Sqlcmd -ServerInstance $Instancename -Database $dbname -Query $createquery