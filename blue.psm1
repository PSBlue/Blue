$Script:thismodulepath = $psscriptroot

#Load function files
Get-ChildItem $psscriptroot\Auth\*.ps1 | Foreach-Object { . $_.FullName }
Get-ChildItem $psscriptroot\Rest\*.ps1 | Foreach-Object { . $_.FullName }
Get-ChildItem $psscriptroot\ResourceGroups\*.ps1 | Foreach-Object { . $_.FullName }

#Setup internal variables
[string]$script:CurrentSubscriptionId = $null
[string]$script:AuthToken = $null
[string]$script:RefreshToken = $null
[Nullable[System.DateTimeOffset]]$script:TokenExpirationUtc = $null
$Script:AllSubscriptions = @()

#Pre-Canned variables
$Script:LoginUrl = "https://login.windows.net/common/oauth2/authorize"
$Script:ResourceUrl = "https://management.core.windows.net/"
$Script:DefaultAuthRedirectUri = "urn:ietf:wg:oauth:2.0:oob"
$Script:DefaultClientId = "1950a258-227b-4e31-a9cf-717495945fc2"

#Other Defaults
$Script:PsDefaultParameterValues.Add("Invoke-RestMethod:Verbose",$False)