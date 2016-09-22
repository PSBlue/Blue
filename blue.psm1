$Script:thismodulepath = $psscriptroot

#Load function files
Get-ChildItem $psscriptroot\Auth\*.ps1 | Foreach-Object { . $_.FullName }
Get-ChildItem $psscriptroot\Rest\*.ps1 | Foreach-Object { . $_.FullName }
Get-ChildItem $psscriptroot\ResourceGroup\*.ps1 | Foreach-Object { . $_.FullName }
Get-ChildItem $psscriptroot\Resource\*.ps1 | Foreach-Object { . $_.FullName }
Get-ChildItem $psscriptroot\VirtualMachine\*.ps1 | Foreach-Object { . $_.FullName }
Get-ChildItem $psscriptroot\Network\*.ps1 | Foreach-Object { . $_.FullName }
Get-ChildItem $psscriptroot\Automation\*.ps1 | Foreach-Object { . $_.FullName }
Get-ChildItem $psscriptroot\Helpers\*.ps1 | Foreach-Object { . $_.FullName }
Get-ChildItem $psscriptroot\TemplateDeployment\*.ps1 | Foreach-Object { . $_.FullName }

#Setup internal variables. These will be filled by Connect-ArmSubscription and should not be manipulated directly other functions.
[string]$script:CurrentSubscriptionId = $null
[string]$script:AuthToken = $null
[string]$script:RefreshToken = $null
[Nullable[System.DateTimeOffset]]$script:TokenExpirationUtc = $null
$Script:AllSubscriptions = @()
$Script:AutomationAccount = $null

#Pre-Canned variables
$Script:LoginUrl = "https://login.microsoftonline.com/common/oauth2/authorize"
$Script:ResourceUrl = "https://management.core.windows.net/"
$Script:DefaultAuthRedirectUri = "urn:ietf:wg:oauth:2.0:oob"
$Script:DefaultClientId = "1950a258-227b-4e31-a9cf-717495945fc2"
$Script:AzureServiceLocations = @()
$Script:ImageSearchApiUrl = "http://blueimageapiweb.azurewebsites.net/api"

#Other Defaults - verboseing web/rest requests is too noisy
$Script:PsDefaultParameterValues.Add("Invoke-RestMethod:Verbose",$False)
$Script:PsDefaultParameterValues.Add("Invoke-WebRequest:Verbose",$False)

#Load autoload classes. Every file in Classes\Autoload needs to be a valid .cs file
$Files = Get-ChildItem (Join-path $Script:thismodulepath "Classes\AutoLoad")
Write-verbose "Loading types in folder Classes\AutoLoad"
add-Type -Path ($Files | select -ExpandProperty FullName)

<#
foreach ($file in $files)
{
    
}
#>

#Load tab completers
<#
if (get-module TabExpansionPlusPlus -list -ErrorAction 0)
{
    Write-verbose "Module TabExpansionPlusPlus found, loading argument completer scripts"
    $CompleterScriptList = Get-ChildItem -Path $PSScriptRoot\Completers\*.ps1
    foreach ($CompleterScript in $CompleterScriptList) {
        Write-Verbose -Message ('Import argument completer script: {0}' -f $CompleterScript.FullName)
        . $CompleterScript.FullName
    }
    Write-Verbose -Message 'Finished importing argument completer scripts.'    
}
#>

