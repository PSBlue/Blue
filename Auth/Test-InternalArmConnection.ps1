Function Test-InternalArmConnection
{
	if ((!$script:CurrentSubscriptionId) -or (!$script:AuthToken))
	{
		return $false	
	}
	Else
	{
		return $true
	}
	
}