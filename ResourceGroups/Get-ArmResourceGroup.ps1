Function Get-ArmResourceGroup
{
    [CmdletBinding()]
	Param (
        [String]$Name,
		[String]$TagName,
        [String]$TagValue
	)
    
    if (!(Test-InternalArmConnection))
    {
        Write-Error "Please use Connect-ArmSubscription"
        return
    }

    $Uri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)/resourcegroups"

    if ($Name)
    {
        $Uri = "$uri/$Name"
        $ResourceGroups = Get-InternalRest -Uri $Uri -ReturnType "Blue.ResourceGroup" -ReturnTypeSingular $true
    }
    Else
    {
        $ResourceGroups = Get-InternalRest -Uri $Uri -ReturnType "Blue.ResourceGroup" -ReturnTypeSingular $false
    }

    $ResourceGroups
    


	
}