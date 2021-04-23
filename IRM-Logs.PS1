Install-Module exchangeonlinemanagement
Install-Module AipService

$cred = Get-Credential

# desktop/MS-Logs+Timestamp
$ts = Get-Date -Format yyyyMMdd_hhmmss
$DesktopPath = ([Environment]::GetFolderPath('Desktop'))
$logsPATH = mkdir "$DesktopPath\MS-Logs\IRM_LOGS_$ts"

Start-Transcript "$logsPATH\IRM_LOGS_$ts.txt"
$FormatEnumerationLimit = -1

# connect-exchangeonline -Credential $cred
Connect-IPPSSession -Credential $cred

Get-LabelPolicyRule | Format-List > $logsPATH\LabelPolicyRules.txt
Get-LabelPolicy | Format-List > $logsPATH\Labelpolicies.txt
Get-Label | Format-List > $logsPATH\Label.txt

# Install-Module AipService
Connect-AipService -Credential $cred

Get-AipServiceConfiguration | Format-List > $logsPATH\AipServiceConfiguration.txt

Get-AipService | Format-List > $logsPATH\AipService.txt

Get-IRMConfiguration | Format-List > $logsPATH\IRMConfiguration_before.txt

Get-AipServiceOnboardingControlPolicy | Format-List > $logsPATH\AipServiceOnboardingControlPolicy.txt
Get-AipServiceOnboardingControlPolicy | Export-Clixml $logsPATH\AipServiceOnboardingControlPolicy.xml

$EndPoint=(Get-AipServiceConfiguration).LicensingExtranetDistributionPointUrl

Set-IRMConfiguration -LicensingLocation $EndPoint

Set-IRMConfiguration -InternalLicensingEnabled:$true -AzureRMSLicensingEnabled:$true -AutomaticServiceUpdateEnabled:$true -SimplifiedClientAccessEnabled:$true

Get-IRMConfiguration | Format-List > $logsPATH\IRMConfiguration_after.txt

$templates = get-aipservicetemplate
$templates | fl > $logsPATH\templates_before.txt
$templates | fl * -f > $logsPATH\templates_Full_before.txt
$templates | Export-Clixml $logsPATH\templates_before.XML
$Templates | FL Status,TemplateID,ScopedIdentities,RightsDefinitions

$Templates | FL Status,names,TemplateID,ScopedIdentities,RightsDefinitions

foreach ($Template in $templates) { Write ("-" * 60) ; $Template | FL Status,TemplateID,ScopedIdentities,RightsDefinitions ; $Template ; $Template.descriptions | where { $_.key -eq "1033" } }

# publish Selected Templates
$Selection = $templates | Out-GridView -T "Select Templates to publish" -PassThru
foreach ($Template in $Selection) { Set-AipServiceTemplateProperty -TemplateId $Template.TemplateID.Guid -Status Published }

# to publish ALL existing Templates
foreach ($Template in $templates) { Set-AipServiceTemplateProperty -TemplateId $Template.TemplateID.Guid -Status Published }

$templates = get-aipservicetemplate
$templates | fl > $logsPATH\templates_After.txt
$templates | fl * -f > $logsPATH\templates_Full_After.txt
$templates | ConvertTo-Json > $logsPATH\templates_After.JSON
$templates | Export-Clixml $logsPATH\templates_after.XML
$Templates | FL Status,TemplateID,ScopedIdentities,RightsDefinitions

Stop-Transcript

Compress-Archive -Path $logsPATH -DestinationPath "$DesktopPath\MS-Logs\IRM_LOGS_$ts.zip" -Force # Zip Logs

Invoke-Item $DesktopPath\MS-Logs # open file manager