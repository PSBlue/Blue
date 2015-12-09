Function Connect-ArmSubscription
{
	[CmdletBinding(DefaultParameterSetName='VisibleCredPrompt',SupportsShouldProcess=$true)]
	[OutputType([PsObject])]
	Param (
		[Parameter(Mandatory=$true,ParameterSetName='ConnectByCredObject')]
		[System.Management.Automation.PSCredential]$Credential,
		
		[Parameter(Mandatory=$False,ParameterSetName='VisibleCredPrompt')]
		[switch]$ForceShowUi,
				
		[String]$SubscriptionId
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
		
		$Result = Get-InternalRest -Uri "https://management.azure.com/tenants" -BearerToken $AuthResult.AccessToken
	}
	Else
	{
		Write-error "Error Authenticating"
        Return
	}
	
    if (!$result)
    {
        Write-error "Error Authenticating"
        Return
    }
    
    #Create an array to hold the list of tenants, subscriptions and auth tokens
    $TenantAuthMap = @()

	$Tenants = $Result.Value
    Foreach ($Tenant in $Tenants)
    {
        
        $PromptBehavior = [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Never
        $TenantAuthContext = New-Object -TypeName Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext -ArgumentList ("https://login.windows.net/$($Tenant.tenantId)/oauth2/authorize")	
        

        Try
        {
            #Try auth with a hidden window first
            $TenantauthResult = $TenantAuthContext.AcquireToken($Script:ResourceUrl,$Script:DefaultClientId, $Script:DefaultAuthRedirectUri, $PromptBehavior)
        }
        Catch
        {
            #If that didn't work, flash the ugly window
            $PromptBehavior = [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Auto
            $TenantauthResult = $TenantAuthContext.AcquireToken($Script:ResourceUrl,$Script:DefaultClientId, $Script:DefaultAuthRedirectUri, $PromptBehavior)
        }

        $SubscriptionResult = $Result = Get-InternalRest -Uri "https://management.azure.com/subscriptions" -BearerToken $TenantauthResult.AccessToken
        foreach ($Subscription in $SubscriptionResult.Value)
        {
            $SubObj = "" | Select SubscriptionId,TenantId,AccessToken,RefreshToken, Expiry, SubscriptionObject
            $subobj.SubscriptionId = $Subscription.subscriptionId
            $subobj.TenantId = $Tenant.tenantId
            $subobj.AccessToken = $TenantAuthResult.AccessToken
            $subobj.RefreshToken = $TenantauthResult.RefreshToken
            $subobj.Expiry = $TenantauthResult.ExpiresOn
            $subobj.SubscriptionObject = $Subscription
            $TenantAuthMap += $SubObj
        }
    }
	
    #Figure out which subscription to choose
    if ($TenantAuthMap.count -eq 0)
    {
        #Error
    }
    ElseIf ($TenantAuthMap.count -eq 1)
    {
        #Only one returned, make sure its the right one
        if ($SubscriptionId)
        {
            if ($SubscriptionId -ne $TenantAuthMap[0].SubscriptionId)
            {
                #We got authenticated, but not to the requested subscription
                Write-error "We got authenticated, but not to the requested subscription"
                Return
            }
            Else
            {
                #return the subscription
                $script:AuthToken = $TenantAuthMap[0].AccessToken
                $Script:RefreshToken = $TenantAuthMap[0].RefreshToken
                $script:TokenExpirationUtc = $TenantAuthMap[0].Expiry
                Return $TenantAuthMap[0].SubscriptionObject
            }
        }
        Else
        {
            #return the subscription
            Return $TenantAuthMap[0].SubscriptionObject
        }
    }
    ElseIf ($TenantAuthMap.count -gt 1)
    {
        #Multiple returned, make surethe specified is in the list
        if (($TenantAuthMap | select -ExpandProperty SubscriptionId ) -notcontains $SubscriptionId)
        {
            #none of the returned tenants mached the specified
        }
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