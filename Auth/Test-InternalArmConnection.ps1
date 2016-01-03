Function Test-InternalArmConnection
{
	if ((!$script:CurrentSubscriptionId) -or (!$script:AuthToken))
	{
		return $false	
	}
	Else
	{
		$AuthSuccess = $false
		
		#Test that we can reach the current subscription
		$Uri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)"
		Try 
		{
			$Result =Get-InternalRest -Uri $Uri -apiversion "2015-01-01"
			$AuthSuccess = $true
		}
		Catch
		{
			$AuthSuccess = $false
		}
		
		
        if ($AuthSuccess -eq $false)
        {
            $CurrentSubObj = $Script:AllSubscriptions | where {$_.SubscriptionId -eq $script:CurrentSubscriptionId}
            $RefreshToken = $CurrentSubObj.RefreshToken
            $LoginUrl = $CurrentSubobj.LoginUrl
            Write-verbose "Attempting to update AccessToken using RefreshToken"
            
            $Null = Connect-ArmSubscription -RefreshToken $RefreshToken -LoginUrl $LoginUrl -ErrorAction SilentlyContinue -ErrorVariable connecterr
            if ($ConnectErr)
            {}
            Else
            {
                $AuthSuccess = $true
            }
        }
		
		
		if ($AuthSuccess -eq $true)
		{
			return $true
		}
		
	}
	
}