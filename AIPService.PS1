# thanks to Ezz

Start-Transcript 
 
$FormatEnumerationLimit=-1 

Install-Module AipService 

Import-Module AipService 

Connect-AipService 

Get-AipService | FL

Get-AipServiceConfiguration | FL

$EndPoint = (Get-AipServiceConfiguration).LicensingExtranetDistributionPointUrl

Set-IRMConfiguration -LicensingLocation $EndPoint

$AipParam = @{ InternalLicensingEnabled = $true
               AzureRMSLicensingEnabled = $true
          AutomaticServiceUpdateEnabled = $true
          SimplifiedClientAccessEnabled = $true }

Set-IRMConfiguration @AipParam

Stop-Transcript