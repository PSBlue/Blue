Function Get-ArmResourceGroup
{
    [CmdletBinding()]
	Param (
		[String]$Name
	)
    
    if (!(Test-InternalArmConnection))
    {
        Write-Error "Please use Connect-ArmSubscription"
        return
    }

    $Uri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)/resourcegroups"

    if ($Name)
    {
        $Querys = @{
        "Filter"=$Name
        }	

        $ResourceGroups = Get-InternalRest -Uri $Uri -QueryStrings $Querys
    }
    Else
    {
        $ResourceGroups = Get-InternalRest -Uri $Uri
    }

    $ResourceGroups.Value
    


	
}