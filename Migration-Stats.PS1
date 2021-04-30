# CONNECT Exchange Online
# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Register-PSRepository -Default
# install-module ExchangeOnlineManagement -SkipPublisherCheck
# install-module -name PowershellGet -Force -SkipPublisherCheck
# Uninstall-Module PowershellGet -MaximumVersion "1.0.0.1" -Force -Confirm:$false -EA stop

 IF (!(get-accepteddomain -EA silentlycontinue)) { Connect-ExchangeOnline }

$ts = Get-Date -Format yyyyMMdd_hhmmss ; $FormatEnumerationLimit = -1
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
[String]$logsPATH = [String]$(mkdir "$DesktopPath\MS-Logs\Migration-Stats-$ts")
Start-Transcript "$logsPATH\Migration-Stats-$ts.txt" -Verbose

$MigBatch = get-migrationbatch ; $MigUsers = get-migrationuser ; $MovReqst = Get-MoveRequest
$StatusComplete = @("Completed", "CompletedWithErrors") ; $StatusProgress = @("Synced", "Syncing", "SyncedWithErrors", "Failed", "Completing")
$MigBatchCompleted = $MigBatch | where { $_.status.value -in $StatusComplete } ; $MigUsersInProgess = $MigUsers | where { $_.status -in $StatusProgress }
$MigBatchInProgess = $MigBatch | where { $_.status.value -in $StatusProgress } ; $MigUsersCompleted = $MigUsers | where { $_.status -in $StatusComplete }
$MigUser | FT Identity,Identifier,BatchId,MailboxIdentifier,MailboxEmailAddress,MailboxGuid,Status,StatusSummary,HasUnapprovedSkippedItems,DataConsistencyScore -AutoSize
$MovReqst | FT Id,Identity,Name,Alias,ExternalDirectoryObjectId,ExchangeGuid,Status,BatchName -AutoSize
$MigBatch | FT Identity,Status,State,WorkflowStage,DataConsistencyScore,MigrationType,StartDateTime,LastSyncedDateTime -AutoSize
ForEach ($M in $MigBatch) { [String]$Path = [String]$logsPATH + '\' + [String]$M.Identity + "_$($M.Status.value)_"
Get-MigrationBatch $M.Identity.Id -IncludeReport -DiagnosticInfo "showtimeslots, showtimeline, verbose" | Export-Clixml "$($Path + 'MigrationBatch.xml')" }
ForEach ($M in $MigUsersInProgess) { [String]$Path = [String]$logsPATH + '\' + [String]$M.Identity + "_$($M.BatchId)_$($M.Status)_"
Get-MigrationUserStatistics $M.Identity -IncludeSkippedItems -IncludeReport -DiagnosticInfo "showtimeslots, showtimeline, verbose" | Export-Clixml "$($Path + 'MigrationUser.xml')"
Get-MoveRequest $M.Identity | Export-Clixml "$($Path + '_MoveRequest.xml')"
Get-MoveRequestStatistics $M.Identity -IncludeReport -DiagnosticInfo "showtimeslots, showtimeline, verbose" | Export-Clixml "$($Path + 'MoveRequestStatistics.xml')" }
ForEach ($M in $MigUsersCompleted) { [String]$Path = [String]$logsPATH + '\' + [String]$M.Identity + "_$($M.Status)_"
$MbxStats = Get-MailboxStatistics $M.Identity -IncludeMoveReport -IncludeMoveHistory
$MbxStats | Export-Clixml "$($Path + 'MailboxStatistics.xml')" ; $MbxStats.MoveHistory[0] | Export-Clixml "$($Path + 'MoveReport.xml')" }

Stop-Transcript
$error | Export-Clixml -Depth 4 "$logsPATH\Error-$ts.XML"
Compress-Archive -Path $logsPATH -DestinationPath "$DesktopPath\MS-Logs\Migration-Stats-$ts.zip" # Zip Logs
Invoke-Item $DesktopPath\MS-Logs           # open Logs Folder in file manager
###### END ZIP Logs ########################

###### Error XML - ONLY if necessary #######
$error | Export-Clixml -Depth 4 "$DesktopPath\MS-Logs\Errors-$ts.XML"