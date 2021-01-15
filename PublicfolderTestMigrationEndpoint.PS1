# get IIS logs (onprem) while doing in powershell / Exchange Online

Start-transcript

$Admin = "LOCAL\Admin"

$PFExchangeserver "EXPFEXAMPLE" # Publicfolder Database Server

$Source_Credential = Get-Credential $Admin
# $Source_RemoteMailboxLegacyDN = (Get-Mailbox "ADMIN")[1]).LegacyExchangeDN
$Source_RemoteMailboxLegacyDN = (Get-Mailbox $($Admin -split "\")[1]).LegacyExchangeDN
$Source_RemotePublicFolderServerLegacyDN = (Get-ExchangeServer $PFExchangeserver)[0].ExchangeLegacyDN

$Source_OutlookAnywhereExternalHostName = (Get-OutlookAnywhere)[0].ExternalHostName
# $Source_OutlookAnywhereExternalHostName = "mail.server.com"

# (Get-OutlookAnywhere).ClientAuthenticationMethod
$auth = “Ntlm”

$server = (Get-OutlookAnywhere)[0].Server 
#$server = “Ex2010”

$Param = @{           PublicFolder = $true
                    RPCProxyServer = $Source_OutlookAnywhereExternalHostName
                       Credentials = $Source_Credential
             SourceMailboxLegacyDN = $Source_RemoteMailboxLegacyDN
PublicFolderDatabaseServerLegacyDN = $Source_RemotePublicFolderServerLegacyDN
                    Authentication = $auth }
   Test-MigrationServerAvailability @Param

Stop-transcript
