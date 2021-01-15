# get IIS logs (onprem) while doing in powershell / Exchange Online

Start-transcript

$Source_Credential = Get-Credential <source_domain\PublicFolder_Administrator_Account>

$PFExchangeserver "EXPFEXAMPLE" # Publicfolder Database Server

$Source_RemoteMailboxLegacyDN = (Get-Mailbox <PublicFolder_Administrator_Account>).LegacyExchangeDN

$Source_RemotePublicFolderServerLegacyDN = (Get-ExchangeServer $PFExchangeserver).ExchangeLegacyDN

$Source_OutlookAnywhereExternalHostName = (Get-OutlookAnywhere).ExternalHostName
# $Source_OutlookAnywhereExternalHostName = "mail.mireb.msftonlinerepro.com"

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
