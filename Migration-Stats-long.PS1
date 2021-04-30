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

$MigBatch = get-migrationbatch
$MigUsers = get-migrationuser
$MovReqst = Get-MoveRequest

$StatusComplete = @("Completed", "CompletedWithErrors")
$StatusProgress = @("Synced", "Syncing", "SyncedWithErrors", "Failed", "Completing")

$MigUsersCompleted = $MigUsers | where { $_.status -in $StatusComplete }
$MigUsersInProgess = $MigUsers | where { $_.status -in $StatusProgress }
$MigBatchCompleted = $MigBatch | where { $_.status.value -in $StatusComplete }
$MigBatchInProgess = $MigBatch | where { $_.status.value -in $StatusProgress }

$MigUser | FT Identity,Identifier,BatchId,MailboxIdentifier,MailboxEmailAddress,MailboxGuid,Status,StatusSummary,HasUnapprovedSkippedItems,DataConsistencyScore -AutoSize

$MovReqst | FT Id,Identity,Name,Alias,ExternalDirectoryObjectId,ExchangeGuid,Status,BatchName -AutoSize

$MigBatch | FT Identity,Status,State,WorkflowStage,DataConsistencyScore,MigrationType,StartDateTime,LastSyncedDateTime -AutoSize

ForEach ($M in $MigBatch) { [String]$Path = [String]$logsPATH + '\' + [String]$M.Identity + "_$($M.Status.value)_"
Get-MigrationBatch $M.Identity.Id -IncludeReport -DiagnosticInfo "showtimeslots, showtimeline, verbose" | Export-Clixml "$($Path + 'MigrationBatch.xml')" }

ForEach ($M in $MigUsersInProgess) { [String]$Path = [String]$logsPATH + '\' + [String]$M.Identity + "_$($M.BatchId)_$($M.Status)_"
Get-MigrationUserStatistics $M.Identity -IncludeSkippedItems -IncludeReport -DiagnosticInfo "showtimeslots, showtimeline, verbose" | Export-Clixml "$($Path + 'MigrationUser.xml')"
Get-MoveRequest $M.Identity | Export-Clixml "$($Path + '_MoveRequest.xml')"
Get-MoveRequestStatistics $M.Identity -IncludeReport -DiagnosticInfo "showtimeslots, showtimeline, verbose" | Export-Clixml "$($Path + 'MoveRequestStatistics.xml')" }

Get-MigrationEndpoint -DiagnosticInfo Verbose | Export-Clixml $logsPATH\MigrationEndpoint.xml
Get-MigrationConfig | Export-Clixml $logsPATH\MigrationConfig.xml

ForEach ($M in $MigUsersCompleted) { [String]$Path = [String]$logsPATH + '\' + [String]$M.Identity + "_$($M.Status)_"

$MbxStats = Get-MailboxStatistics $M.Identity -IncludeMoveReport -IncludeMoveHistory
$MbxStats | Export-Clixml "$($Path + 'MailboxStatistics.xml')"
$MbxStats.MoveHistory[0] | Export-Clixml "$($Path + 'MoveReport.xml')"

$SRC_MBX_BEFR = $MbxStats.MoveHistory[0].Report.SourceMailboxBeforeMove.props
$SRC_MBX_BEFR_GUID = $SRC_MBX_BEFR | where { $_.propertyname -like "*exchangeguid" -or $_.propertyname -eq "guid" -or $_.propertyname -like "*archiveguid"}
$SRC_MBX_BEFR_GUID | select propertyname,@{ n = "Value" ;e = { [guid]([System.Convert]::FromBase64String($_.Values.StrValue)) } } >> "$($Path + 'SOURCE_MailBOX_BEFORE.TXT')"
$SRC_MBX_BEFR | where { $_.propertyname -eq "EmailAddresses" } | select propertyname,@{ n = "Value" ; e = { ($_.Values.StrValue) } } | select -expandproperty Value >> "$($Path + 'SOURCE_MailBOX_BEFORE.TXT')"
$SRC_MBX_BEFR | select propertyname,@{ n = "Value" ;e = { ($_.values) } } >> "$($Path + 'SOURCE_MailBOX_BEFORE.TXT')"

$SRC_USR_AFTR = $MbxStats.MoveHistory[0].Report.SourceMailUserAfterMove.props
$SRC_USR_AFTR_GUID = $SRC_USR_AFTR | where { $_.propertyname -like "*exchangeguid" -or $_.propertyname -eq "guid" -or $_.propertyname -like "*archiveguid"}
$SRC_USR_AFTR_GUID | select propertyname,@{ n = "Value" ;e = { [guid]([System.Convert]::FromBase64String($_.Values.StrValue)) } } >> "$($Path + 'SOURCE_MailUSER_AFTER.TXT')"
$SRC_USR_AFTR | where { $_.propertyname -eq "EmailAddresses" } | select propertyname,@{ n = "Value" ; e = { ($_.Values.StrValue) } } | select -expandproperty Value >> "$($Path + 'SOURCE_MailUSER_AFTER.TXT')"
$SRC_USR_AFTR | select propertyname,@{ n = "Value" ;e = { ($_.values) } } >> "$($Path + 'SOURCE_MailUSER_AFTER.TXT')"

$TRG_MBX_AFTR = $MbxStats.MoveHistory[0].Report.TargetMailboxAfterMove.props
$TRG_MBX_AFTR_GUID = $TRG_MBX_AFTR | where { $_.propertyname -like "*exchangeguid" -or $_.propertyname -eq "guid" -or $_.propertyname -like "*archiveguid"}
$TRG_MBX_AFTR_GUID | select propertyname,@{ n = "Value" ;e = { [guid]([System.Convert]::FromBase64String($_.Values.StrValue)) } } >> "$($Path + 'TARGET_Mailbox_AFTER.TXT')"
$TRG_MBX_AFTR | where { $_.propertyname -eq "EmailAddresses" } | select propertyname,@{ n = "Value" ; e = { ($_.Values.StrValue) } } | select -expandproperty Value >> "$($Path + 'TARGET_Mailbox_AFTER.TXT')"
$TRG_MBX_AFTR | select propertyname,@{ n = "Value" ;e = { ($_.values) } } >> "$($Path + 'TARGET_Mailbox_AFTER.TXT')"

$TRG_USR_BEFR = $MbxStats.MoveHistory[0].Report.TargetMailUserBeforeMove.props
$TRG_USR_BEFR_GUID = $TRG_USR_BEFR | where { $_.propertyname -like "*exchangeguid" -or $_.propertyname -eq "guid" -or $_.propertyname -like "*archiveguid"}
$TRG_USR_BEFR_GUID | select propertyname,@{ n = "Value" ;e = { [guid]([System.Convert]::FromBase64String($_.Values.StrValue)) } } >> "$($Path + 'TARGET_MailUSER_BEFORE.TXT')"
$TRG_USR_BEFR | where { $_.propertyname -eq "EmailAddresses"} | select PropertyName,@{ n = "Value" ;e = { ($_.values.StrValue) } } | select -expandproperty Value >> "$($Path + 'TARGET_MailUSER_BEFORE.TXT')"
$TRG_USR_BEFR | select propertyname,@{ n = "Value" ;e = { ($_.values) } } >> "$($Path + 'TARGET_MailUSER_BEFORE.TXT')" }

Stop-Transcript
Compress-Archive -Path $logsPATH -DestinationPath "$DesktopPath\MS-Logs\Migration-Stats-$ts.zip" # Zip Logs
Invoke-Item $DesktopPath\MS-Logs # open Logs Folder in Filemanager
###### END ZIP Logs ########################