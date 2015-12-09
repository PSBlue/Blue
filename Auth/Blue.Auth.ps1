Function Connect-ArmSubscription
{
	[CmdletBinding(DefaultParameterSetName='VisibleCredPrompt',SupportsShouldProcess=$true)]
	[OutputType([PsObject])]
	Param (
		[Parameter(Mandatory=$true,ParameterSetName='ConnectByCredObject')]
		[System.Management.Automation.PSCredential]$Credential,
		
		[Parameter(Mandatory=$False,ParameterSetName='VisibleCredPrompt')]
		[switch]$ForceShowUi,
				
		[String]$SubscriptionId,
		[String]$SubscriptionName
	)
	if ($Script:AuthContext -eq $null)
	{
		$script:AuthContext = New-Object -TypeName Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext -ArgumentList ($Script:LoginUrl)	
	}
	
	Write-Debug "Logging on using Parameter set $($PSCmdlet.ParameterSetName)"
	
	if ($PSCmdlet.ParameterSetName -eq "VisibleCredPrompt")
	{
		if ($ForceShowUi -eq $true)
		{
			$PromptBehavior = [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Always	
		}
		Else
		{
			$PromptBehavior = [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Auto
		}
		
		Try 
		{
			$authResult = $script:authContext.AcquireToken($Script:ResourceUrl,$Script:DefaultClientId, $Script:DefaultAuthRedirectUri, $PromptBehavior)	
		}
		Catch
		{
			#Error-handling here
		}
		
	}
	
	if ($authResult)
	{
		$script:AuthToken = $AuthResult.AccessToken
		$Script:RefreshToken = $AuthResult.RefreshToken
		$script:TokenExpirationUtc = $AuthResult.ExpiresOn
		
		Write-Verbose -Message "Authenticated as $($AuthResult.UserInfo.DisplayableId)"
		
		$Url = "https://management.azure.com/subscriptions&api-version=2015-01-01"
		$headers = @{
			"x-ms-version"="2015-01-01";
			"Content-Type"="application/json";
			"Authorization"="Bearer $($AuthResult.AccessToken)"
			}
		$Result = Invoke-RestMethod -Headers $headers -uri $Url -Method Get
		$Result
	}
	Else
	{
		Write-error "Error Authenticating"
	}
	
	
	
	
	[string]$script:CurrentSubscriptionId = $SubscriptionId
}

Function Get-InternalAuthDetails
{
	Write-output $script:AuthToken
	Write-output $Script:RefreshToken
	Write-output $script:TokenExpirationUtc
}

Function Get-ArmSubscription
{
	Param (
	)
	
	Get-InternalAuthDetails
}