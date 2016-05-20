Function Connect-ArmSubscription
{
	[CmdletBinding(DefaultParameterSetName='VisibleCredPrompt',SupportsShouldProcess=$true)]
	[OutputType([PsObject])]
	Param (
		[Parameter(Mandatory=$true,ParameterSetName='ConnectByCredObject')]
		[System.Management.Automation.PSCredential]$Credential,
		
		[Parameter(Mandatory=$False,ParameterSetName='VisibleCredPrompt')]
		[switch]$ForceShowUi,
		
        [Parameter(Mandatory=$True,ParameterSetName='ConnectByRefreshToken')]
        [String]$RefreshToken,

        [Parameter(Mandatory=$True,ParameterSetName='ConnectByRefreshToken')]
        [String]$LoginUrl,
		
		[String]$SubscriptionId,
        
        [String]$TenantId,

        [Switch]$BasicOutput
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
    ElseIf($PScmdlet.ParameterSetName -eq "ConnectByRefreshToken")
    {
        $AuthResult = Get-InternalAcquireToken -RefreshToken $RefreshToken -ClientId $Script:DefaultClientId -LoginUrl $LoginUrl -resourceUrl $Script:ResourceUrl
        if ($AuthResult)
        {
            $script:AuthToken = $AuthResult.AccessToken
            $Script:RefreshToken = $AuthResult.RefreshToken
            $script:TokenExpirationUtc = $AuthResult.ExpiresOn

            #Remove the current subscription object from the array
            
            $CurrentSub = $Script:AllSubscriptions | where {$_.SubscriptionId -eq $script:CurrentSubscriptionId}
            $Script:AllSubscriptions = $Script:AllSubscriptions | where {$_.SubscriptionId -ne $script:CurrentSubscriptionId}
            

            $SubObj = "" | Select SubscriptionId,TenantId,AccessToken,RefreshToken, Expiry, SubscriptionObject, DisplayName, State, LoginUrl
            $subobj.SubscriptionId = $script:CurrentSubscriptionId
            $subobj.DisplayName = $CurrentSub.displayName
            $SubObj.State = $CurrentSub.state
            $subobj.TenantId = $CurrentSub.tenantId
            $subobj.AccessToken = $AuthResult.AccessToken
            $subobj.RefreshToken = $AuthResult.RefreshToken
            $subobj.Expiry = $AuthResult.ExpiresOn
            $subobj.SubscriptionObject = $CurrentSub.SubscriptionObject
            $subobj.LoginUrl = $CurrentSub.LoginUrl
            
            #Add it back to the array. At this point, subobj will contain the updated access/refresh tokens, and the updated exirys
            $Script:AllSubscriptions += $subobj
            
            #$ThisSubsciption.AccessToken = $script:AuthToken
            #$ThisSubsciption.RefreshToken = $Script:RefreshToken
            #$ThisSubsciption.Expiry = $script:TokenExpirationUtc
        }
        Else
        {
            #Error
        }

        Return
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
		
		$Result = Get-InternalRest -Uri "https://management.azure.com/tenants" -BearerToken $AuthResult.AccessToken -ApiVersion "2015-01-01"
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
    
    if ($PScmdlet.ParameterSetName -ne "ConnectByRefreshToken")
    {
        #Create an array to hold the list of tenants, subscriptions and auth tokens
        $TenantAuthMap = @()
        $ThisSubscription = $null
	    $Tenants = $Result.Value
    
        if ($TenantId)
        {
            $Tenants = $Tenants | where {$_.TenantId -eq $TenantId}
            if ($Tenants -eq $null)
            {
                Write-Error "The logged on user is not connected to tenant $tenantId"
                Return
            }
        }
    
    

    
        Foreach ($Tenant in $Tenants)
        {
        
            Write-verbose "Listing Subscriptions in tenant $($Tenant.tenantId)"
            $params["PromptBehavior"] = "Suppress"
            $Params["LoginUrl"] = "https://login.windows.net/$($Tenant.tenantId)/oauth2/authorize/"
            $TenantauthResult = Get-InternalAcquireToken @Params
        
            Write-Debug "Using access key $($TenantauthResult.AccessToken)"
            $SubscriptionResult  = Get-InternalRest -Uri "https://management.azure.com/subscriptions" -BearerToken $TenantauthResult.AccessToken -Apiversion "2015-01-01"
            if ($SubscriptionResult.Value.count -gt 0)
            {
                foreach ($Subscription in $SubscriptionResult.Value)
                {
                    Write-verbose "     Found subscription $($Subscription.subscriptionId)"
                    $SubObj = "" | Select SubscriptionId,TenantId,AccessToken,RefreshToken, Expiry, SubscriptionObject, DisplayName, State, LoginUrl
                    $subobj.SubscriptionId = $Subscription.subscriptionId
                    $subobj.DisplayName = $Subscription.displayName
                    $SubObj.State = $Subscription.state
                    $subobj.TenantId = $Tenant.tenantId
                    $subobj.AccessToken = $TenantAuthResult.AccessToken
                    $subobj.RefreshToken = $TenantauthResult.RefreshToken
                    $subobj.Expiry = $TenantauthResult.ExpiresOn
                    $subobj.SubscriptionObject = $Subscription
                    $subobj.LoginUrl = "https://login.windows.net/$($Tenant.tenantId)/oauth2/authorize/"
                    $TenantAuthMap += $SubObj
                }
            }
            Else
            {
                Write-verbose "     Zero subscriptions found in tenant"
            }
        
        }
    
        #Add all subscriptions to global var
        $Script:AllSubscriptions = $TenantAuthMap
	
        #Figure out which subscription to choose
        if ($TenantAuthMap.count -eq 0)
        {
            #Error
        }
        ElseIf ($TenantAuthMap.count -gt 1 -and $SubscriptionId)
        {
            #Multiple returned, make surethe specified is in the list
            if (($TenantAuthMap | select -ExpandProperty SubscriptionId ) -notcontains $SubscriptionId)
            {
                Write-Error "specified subscriptionId $SubscriptionId was not found for tenant" -ErrorAction Stop
            }
        }
        ElseIf ($TenantAuthMap.count -eq 1)
        {
            #Only one returned, make sure its the right one
        
            #return the subscription
            $script:AuthToken = $TenantAuthMap[0].AccessToken
            $Script:RefreshToken = $TenantAuthMap[0].RefreshToken
            $script:TokenExpirationUtc = $TenantAuthMap[0].Expiry
            $script:CurrentSubscriptionId = $TenantAuthMap[0].SubscriptionId
            $ThisSubscription =  $TenantAuthMap[0]               
         
        }
        ElseIf ($TenantAuthMap.count -gt 1) {
            Write-Warning -Message "Multiple Subscriptions found and none specified. Please select the desired one"
            $i = 0
            $list = foreach ($T in $TenantAuthMap) {
                $i++
                '[{0}] - {1} - {2}' -f $i,$T.DisplayName,$T.SubscriptionId
            }
            do {
                $result = Read-Host -Prompt "Enter the index number of the desired subscription: `n$($List | Out-String)"
            } while ($result -gt $TenantAuthMap.count -or $result -eq 0)
            $script:AuthToken = $TenantAuthMap[$result -1].AccessToken
            $Script:RefreshToken = $TenantAuthMap[$result -1].RefreshToken
            $script:TokenExpirationUtc = $TenantAuthMap[$result -1].Expiry
            $ThisSubscription =  $TenantAuthMap[$result -1]
        }

        $script:CurrentSubscriptionId = $ThisSubscription.SubscriptionId
        $script:AuthToken = $ThisSubscription.AccessToken
        $script:RefreshToken = $ThisSubscription.AccessToken
        $script:TokenExpirationUtc = $ThisSubscription.Expiry
    
        #Grab the available locations for the subscriptions
        $LocationsResult = Get-InternalRest -Uri "https://management.azure.com/subscriptions/$script:CurrentSubscriptionId/locations" -ReturnType "Blue.AzureServiceLocation" -ReturnTypeSingular $false -ApiVersion "2015-01-01"
        $Script:AzureServiceLocations = $LocationsResult


        if ($BasicOutput)
        {
            return $ThisSubscription.SubscriptionId
        }
        Else
        {
            return $ThisSubscription.SubscriptionObject
        }
    
    }

    

	
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