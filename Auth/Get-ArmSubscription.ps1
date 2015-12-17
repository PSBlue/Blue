<#
.Synopsis
   Lists information about available subscriptions
#>
Function Get-ArmSubscription
{
    [CmdletBinding(DefaultParameterSetName='AllSUbs')]
	Param (
        # List only the currently connected subscription
        [Parameter(Mandatory=$true,ParameterSetName='CurrentSub')]
		[Switch]$Current,
        
        [Parameter(ParameterSetName='CurrentSub')]
        [Switch]$IncludeAccessKey
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
            $thisSub = $AllSubs | where {$_.SubscriptionId -eq $script:CurrentSubscriptionId}
            
        }
        Else
        {
            Write-warning "Not currently connected to a subscription"
            return
        }
        
        if ($IncludeAccessKey -eq $true)
        {
            Return $ThisSub | Select SubscriptionId, TenantId, SubscriptionObject, AccessToken
        }
        Else
        {
            Return $ThisSub | Select SubscriptionId, TenantId, SubscriptionObject
        }
        
    }
    
    
    


	
}