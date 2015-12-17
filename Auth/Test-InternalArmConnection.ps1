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
			$Result =Get-InternalRest -Uri $Uri
			$AuthSuccess = $true
		}
		Catch
		{
			$AuthSuccess = $false
		}
		
		
		
		
		if ($AuthSuccess -eq $true)
		{
			return $true
		}
		
	}
	
}