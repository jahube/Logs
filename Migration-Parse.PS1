$path = $Env:USERPROFILE + '\Downloads'
$folder = "Public_Folder_Migration_Stats_20201230_052649"
$file = "EXO_PFMigReq.xml"
$data = import-clixml $path\$folder\$file
$data.report | fl *entries*

@(@($data.DiagnosticInfo -split "<")[1] -split '>')[0] -replace '="',': ' -replace '" ',"`n"
#$properties = (($data.Report.sourcethrottles | get-member) | where { $_.Membertype -eq 'Property' }).name

# Foreach ($P in $properties) { $data.Report.sourcethrottles.$P | where { $_ -ne '0' }}
# $target = Foreach ($P in $properties) { $data.Report.targetthrottles."$P" | where { $_ -ne '0' } }| $target.TotalHours }

$data.Report.sourcethrottles| ft MdbAvailabilityThrottle,DiskLatencyThrottle,CpuThrottle
$data.Report.targetthrottles| ft MdbAvailabilityThrottle,DiskLatencyThrottle,CpuThrottle
$data.Report.internalfailures | fl failuretype,workitem

@($data.Report.internalfailures.message -split "diagnostic context")[0] -replace '-->',"`n`n-->  "
# $data.DiagnosticInfo

@(@($data.DiagnosticInfo -split "<skippeditemcounts")[1] -split '</skippeditemcounts>')[0] -replace '<C Kind="','Type: ' -replace '" KindInt="1" Cat="','  Category: ' -replace '" ScoringClassification="','  Score: ' -replace '" Num="','  Count: ' -replace '"></C>',''
@(@($data.DiagnosticInfo -split "<baditemcounter>")[1] -split '</baditemcounter>')[0] -replace '<C Kind="','Type: ' -replace '<BadItemScoringType_FolderACL>','FolderACL: ' -replace ' <BadItemScoringType_','' -replace '</BadItemScoringType_','  ' -replace '>','  '

$list = $data.Report.Failures | foreach { $_ | Select-Object @{name="index";expression={$i}},timestamp,failuretype,Message;$index++}
$list | group failuretype,message | select count,name