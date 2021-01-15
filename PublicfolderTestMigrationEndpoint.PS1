# get IIS logs (onprem) while doing in powershell / Exchange Online

#short
Start-transcript

$Admin = "LOCAL\Admin"
$ExchServerPF "EX01PF" # Exchange PF DB 
$auth = “Ntlm”

$Source_Credential = Get-Credential $Admin
$Source_RemoteMBXDN = (Get-Mailbox $($Admin -split "\\")[1]).LegacyExchangeDN
$SourcePFDBServerDN = (Get-ExchangeServer $ExchServerPF)[0].ExchangeLegacyDN
$OutlookAnywhereEHN = (Get-OutlookAnywhere)[0].ExternalHostName
$Param = @{           PublicFolder = $true
                    RPCProxyServer = "$OutlookAnywhereEHN"
                       Credentials = $Source_Credential
             SourceMailboxLegacyDN = "$Source_RemoteMBXDN"
PublicFolderDatabaseServerLegacyDN = "$SourcePFDBServerDN"
                    Authentication = $auth }
   Test-MigrationServerAvailability @Param

Stop-transcript


#test

$ExchSrvPF "EX01PF" # Exchange PF DB 

$Source_Credential = Get-Credential "LOCAL\Administrator"

$Source_RemoteMBXDN = (Get-Mailbox $($Admin -split "\\")[1]).LegacyExchangeDN
$SourcePFDBServerDN = (Get-ExchangeServer $ExchSrvPF)[0].ExchangeLegacyDN
$OutlookAnywhereEHN = (Get-OutlookAnywhere)[0].ExternalHostName
$Param = @{           PublicFolder = $true
                    RPCProxyServer = "$OutlookAnywhereEHN"
                       Credentials = $Source_Credential
             SourceMailboxLegacyDN = "$Source_RemoteMBXDN"
PublicFolderDatabaseServerLegacyDN = "$SourcePFDBServerDN"
                    Authentication = “Ntlm” }
   Test-MigrationServerAvailability @Param


# long

Start-transcript

$Admin = "LOCAL\Admin"

$ExchServerPF "EX01PF" # Exchange PF DB 

$Source_Credential = Get-Credential $Admin
$Source_RemoteMailboxLegacyDN = (Get-Mailbox $($Admin -split "\")[1]).LegacyExchangeDN
#   $Source_RemoteMailboxLegacyDN = (Get-Mailbox "ADMIN")[1]).LegacyExchangeDN
$Source_RemotePublicFolderServerLegacyDN = (Get-ExchangeServer $ExchServerPF)[0].ExchangeLegacyDN
$Source_OutlookAnywhereExternalHostName = (Get-OutlookAnywhere)[0].ExternalHostName
#   $Source_OutlookAnywhereExternalHostName = "mail.server.com"
$auth = “Ntlm”
#   (Get-OutlookAnywhere).ClientAuthenticationMethod

$server = (Get-OutlookAnywhere)[0].Server
#$server = “Ex2010”

$Param = @{           PublicFolder = $true
                    RPCProxyServer = "$Source_OutlookAnywhereExternalHostName"
                       Credentials = $Source_Credential
             SourceMailboxLegacyDN = "$Source_RemoteMailboxLegacyDN"
PublicFolderDatabaseServerLegacyDN = "$Source_RemotePublicFolderServerLegacyDN"
                    Authentication = $auth }
   Test-MigrationServerAvailability @Param

Stop-transcript
