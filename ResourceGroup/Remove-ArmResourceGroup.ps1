Function Remove-ArmResourceGroup
{
    [CmdletBinding()]
	Param (
        [Parameter(Mandatory=$true,ParameterSetName='ByObj',ValueFromPipeline=$true)]
        [Blue.ResourceGroup]$InputObject,
        
        [Parameter(Mandatory=$true,ParameterSetName='ByName')]
        [String]$Name
	)
    
    Begin
    {
        if (!(Test-InternalArmConnection))
        {
            Write-Error "Please use Connect-ArmSubscription"
            return
        }
    
        $BaseUri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)/resourcegroups" 
        
        $ResourceGroups = @()   
    }
    Process
    {
        if ($InputObject)
        {
            $Name = $InputObject.Name
        }
        
        
        $Uri = "$Baseuri/$Name"
        $Result = Get-InternalRest -Uri $Uri -method "Delete"
            
    }
    End
    {
            
    }

    
    
    


	
}