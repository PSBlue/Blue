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

	
	Write-Debug "Logging on using Parameter set $($PSCmdlet.ParameterSetName)"
	
	if ($PSCmdlet.ParameterSetName -eq "VisibleCredPrompt")
	{
        $Params = @{}
		if ($ForceShowUi -eq $true)
		{
			$Params.Add("PromptBehavior","Always")
		}
        Else
        {
            $Params.Add("PromptBehavior","Suppress")
        }

        $Params.Add("LoginUrl",$Script:LoginUrl)
        $Params.Add("ResourceUrl",$Script:ResourceUrl)
        $Params.Add("ClientId",$Script:DefaultClientId)
        $Params.Add("RedirectUri",$Script:DefaultAuthRedirectUri)
		
		Try 
		{
			$authResult = Get-InternalAcquireToken @Params -ErrorAction Stop
		}
		Catch
		{
			#Error-handling here
		}
		
	}
    ElseIf($PSCmdlet.ParameterSetName -eq "ConnectByCredObject")
    {    
        $Params = @{}
        $Params.Add("LoginUrl",$Script:LoginUrl)
        $Params.Add("ResourceUrl",$Script:ResourceUrl)
        $Params.Add("ClientId",$Script:DefaultClientId)
        $Params.Add("Credential",$Credential)

        Try 
		{
			$authResult = Get-InternalAcquireToken @Params -ErrorAction Stop
		}
		Catch
		{
			#Error-handling here
		}
    }
    Else
    {
        Write-error "Could not understand how you wanted to log in"
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
        
        
        $params["PromptBehavior"] = "Suppress"
        $Params["LoginUrl"] = "https://login.windows.net/$($Tenant.tenantId)/oauth2/authorize"
        $TenantauthResult = Get-InternalAcquireToken @Params
        

        $SubscriptionResult  = Get-InternalRest -Uri "https://management.azure.com/subscriptions" -BearerToken $TenantauthResult.AccessToken
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
            Write-Error ""
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