# get IIS logs (onprem) while doing in powershell / Exchange Online

Start-transcript

$Admin = "LOCAL\Admin"

$ExchServerPF "EX01PF" # Exchange PF DB 

# \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ #

$Source_Credential = Get-Credential $Admin



$Source_RemoteMBXLegacyDN = (Get-Mailbox $($Admin -split "\")[1]).LegacyExchangeDN
        # $Source_RemoteMailboxLegacyDN = (Get-Mailbox "ADMIN")[1]).LegacyExchangeDN

$SrcRemotePFServerLegacyDN = (Get-ExchangeServer $ExchServerPF)[0].ExchangeLegacyDN

$Source_OutlookAnywhereExternalHostName = (Get-OutlookAnywhere)[0].ExternalHostName
        # $Source_OutlookAnywhereExternalHostName = "mail.server.com"

$auth = “Ntlm”
        # (Get-OutlookAnywhere).ClientAuthenticationMethod

$server = (Get-OutlookAnywhere)[0].Server
#$server = “Ex2010”

$Param = @{           PublicFolder = $true
                    RPCProxyServer = "$Source_OutlookAnywhereExternalHostName"
                       Credentials = $Source_Credential
             SourceMailboxLegacyDN = "$Source_RemoteMBXLegacyDN"
PublicFolderDatabaseServerLegacyDN = "$SrcRemotePFServerLegacyDN"
                    Authentication = $auth }
   Test-MigrationServerAvailability @Param

Stop-transcript
