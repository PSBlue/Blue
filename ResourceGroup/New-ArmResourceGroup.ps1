Function New-ArmResourceGroup
{
	Param (
		[Parameter(Mandatory=$true)]
		[String]$Name,
		[Parameter(Mandatory=$true)]
		[String]$Location,
        [Parameter(Mandatory=$false)]
        [hashtable]$Tags
	)
	
	Begin
    {
        if (!(Test-InternalArmConnection))
        {
            Write-Error "Please use Connect-ArmSubscription"
            return
        }
    
        
    }
	Process
	{
		$Data = "" | Select location
		$Data.Location = $Location
        if ($Tags)
        {
            $Data | add-member -MemberType NoteProperty -Name tags -Value $Tags
        }
		$Uri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)/resourcegroups/$Name"
		$RG = Post-InternalRest -uri $Uri -Data $Data -method "Put" -ReturnType "Blue.ResourceGroup" -ReturnTypeSingular $true -apiversion "2015-01-01"
	}
    End
    {
        if ($RG)
        {
            return $RG
        }
        
    }
}