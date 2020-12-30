$path = $Env:USERPROFILE + '\Downloads'
$folder = "Public_Folder_Migration_Stats_DATE"
$file = "EXO_PFMigReq.xml"
$data = import-clixml $path\$folder\$file

$list = $data.Report.Failures | foreach { $_ | Select-Object @{name="index";expression={$i}},timestamp,failuretype,Message;$index++}

$list | group failuretype,message | select count,name


$data.report | fl *entries*

$data.Report.sourcethrottles| ft

$data.Report.targetthrottles| ft
