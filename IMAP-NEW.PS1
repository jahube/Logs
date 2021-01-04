# connect Powershell ISE to Exchange Online

# install-module exchangeonlinemanagement
# connect-exchangeonline -userprincipalname "ADMIN@DOMAIN.com"

# Open in Powershell ISE {Ctrl+N} and edit the marked below

$Mailbox = "User@contoso.com" # CHANGE
$Batch = "User1 Contoso com"  # CHANGE
$MigrationEndpoint = "IMAP Endpoint mail.contoso.com" # CHANGE

# desktop/MS-Logs+Timestamp
$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH =mkdir "$DesktopPath\MS-Logs\IMAP_Migration_Stats_$ts"

Start-Transcript "$logsPATH\IMAP_Migration_Stats_$ts.txt"
$FormatEnumerationLimit = -1

## choose any of the 2 Examples above and modify
Get-MigrationBatch $Batch -IncludeReport -DiagnosticInfo "showtimeslots, showtimeline, verbose" | Export-Clixml $logsPATH\MigrationBatch_$Batch.xml

Get-MigrationUser $Mailbox | Export-Clixml $logsPATH\MigrationUser_$Mailbox.xml

Get-MigrationUserStatistics $Mailbox -IncludeSkippedItems -IncludeReport -DiagnosticInfo "showtimeslots, showtimeline, verbose" | Export-Clixml $logsPATH\MigrationUserStatistics_$Mailbox.xml

Get-SyncRequest $Mailbox | Export-Clixml C:\Temp\MSSupport\SyncRequest_$Mailbox.xml

Get-SyncRequestStatistics $Mailbox -IncludeReport -DiagnosticInfo "showtimeslots, showtimeline, verbose" | Export-Clixml $logsPATH\SyncRequestStatistics_$Mailbox.xml

# IMAP_Optional
Get-MigrationEndpoint $MigrationEndpoint -DiagnosticInfo Verbose | Export-Clixml $logsPATH\MigrationEndpoint_$MigrationEndpoint.xml

Get-MigrationConfig | Export-Clixml $logsPATH\MigrationConfig.xml

Get-MailboxFolderStatistics $Mailbox -IncludeOldestAndNewestItems -IncludeAnalysis -FolderScope nonipmroot | Export-Clixml $logsPATH\MailboxFolderStatistics_$Mailbox.xml

Stop-Transcript
###### END TRANSCRIPT ######################
$destination = "$DesktopPath\MS-Logs\IMAP_Migration_Stats_$ts.zip"
Add-Type -assembly “system.io.compression.filesystem”
[io.compression.zipfile]::CreateFromDirectory($logsPATH, $destination) # ZIP
Invoke-Item $DesktopPath\MS-Logs # open file manager
###### END ZIP Logs ########################
