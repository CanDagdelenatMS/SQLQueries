
$PrivDictionary= Import-LocalizedData -FileName PrivToUserRight.psd1
$rawfindings= Get-Content .\UserRights.JSON

$hashedfindings= @{}
($rawfindings | ConvertFrom-Json).psobject.properties |Foreach { 
    if ($_.Name -notlike 'RunspaceId' -and $_.Name -notlike 'PSComputerName'  -and $_.Name -notlike 'PSShowComputerName') {$hashedfindings[$_.Name] = $_.Value }}

$translatedfindings= @{}

foreach ($priv in $PrivDictionary.keys) {
$columnname=$PrivDictionary.$priv
$val= $hashedfindings.$priv
$translatedfindings.$columnname = $val
}
$translatedfindings.Computername= $hashedfindings.Computername
$StrColumnNames= $translatedfindings.keys -join ","
#$StrColumnNames=  "`'" + "$StrColumnNames" + "`'"
$StrColumnValues= $translatedfindings.values -join "`',`'"
$StrColumnValues =  "`'" + "$StrColumnValues" +  "`'"
$InsertQuery= @"
INSERT INTO UserRights ($StrColumnNames)
VALUES ($StrColumnValues)
"@


$dbname= "tester"
$servername="node1"
Invoke-Sqlcmd -ServerInstance $servername -Database $dbname -Query $InsertQuery

