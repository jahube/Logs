
$Mailbox = "User@contoso.com" # < -- <AffectedMailbox>

$Batch = "User1 Contoso com"  # < -- <BatchName>

$ts = Get-Date -Format yyyyMMdd_hhmmss ; $FormatEnumerationLimit = -1
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\Migration-Stats-$ts"
Start-Transcript "$logsPATH\Migration-Stats-$ts.txt" -Verbose

$Migbatch = Get-MigrationBatch $Batch -IncludeReport -DiagnosticInfo "showtimeslots, showtimeline, verbose" 
$Migbatch | Export-Clixml $logsPATH\MigrationBatch_$Batch.xml
$Miguser = Get-MigrationUser $Mailbox
$Miguser | Export-Clixml $logsPATH\MigrationUser_$Mailbox.xml
$Migstats = Get-MigrationUserStatistics $Mailbox -IncludeSkippedItems -IncludeReport -DiagnosticInfo "showtimeslots, showtimeline, verbose" 
$Migstats | Export-Clixml $logsPATH\MigrationUserStatistics_$Mailbox.xml
$MoveReq = Get-MoveRequest $Mailbox 
$MoveReq | Export-Clixml $logsPATH\MoveRequest_$Mailbox.xml
$MoveReqStats = Get-MoveRequestStatistics $Mailbox -IncludeReport -DiagnosticInfo "showtimeslots, showtimeline, verbose" 
$MoveReqStats | Export-Clixml $logsPATH\MoveRequestStatistics_$Mailbox.xml

# Hybrid_Optional
Get-MigrationEndpoint -DiagnosticInfo Verbose | Export-Clixml $logsPATH\MigrationEndpoint.xml
Get-MigrationConfig | Export-Clixml $logsPATH\MigrationConfig.xml

### If the move completed
$MailboxStats = Get-MailboxStatistics $Mailbox -IncludeMoveReport -IncludeMoveHistory 
$MailboxStats | Export-Clixml $logsPATH\MailboxStatistics_$Mailbox.xml
$Move = Get-MailboxStatistics $Mailbox -IncludeMoveReport -IncludeMoveHistory
$Move.MoveHistory[0] | Export-Clixml $logsPATH\MoveReport.xml

Stop-Transcript

$destination = "$DesktopPath\MS-Logs\Migration-Stats-$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager