<#
.Synopsis
   Lists information about available subscriptions
#>
Function Get-ArmSubscription
{
	Param (
        # List only the currently connected subscription
		[Switch]$Current
	)
	
    if ($Script:AllSubscriptions.count -eq 0)
    {
        Write-Warning "Not connected to Azure. Run Connect-ArmSubscription to connect."
        Return
    }


	$AllSubs = $Script:AllSubscriptions

    if ($Current -eq $false)
    {
        $AllSubs | Select SubscriptionId,TenantId,SubscriptionObject
    }
    Else
    {
        if ($script:CurrentSubscriptionId -ne $null)
        {
            #Display the current subscription
            $AllSubs | Select SubscriptionId,TenantId,SubscriptionObject | where {$_.SubscriptionId -eq $script:CurrentSubscriptionId}
        }
        Else
        {
            Write-warning "Not currently connected to a subscription"
        }
        
    }
    


	
}