Function Get-ArmResourceGroup
{
    [CmdletBinding()]
	Param (
        [Parameter(Mandatory=$true,ParameterSetName='ByObj',ValueFromPipeline=$true)]
        [Blue.ResourceGroup]$InputObject,
        
        [Parameter(Mandatory=$false,ParameterSetName='ByName')]
        [String]$Name,
        
        [Parameter(Mandatory=$false,ParameterSetName='ByName')]
        [String]$Location,
        
        [Parameter(Mandatory=$false,ParameterSetName='ByName')]
		[String]$TagName,
        
        [Parameter(Mandatory=$false,ParameterSetName='ByName')]
        [String]$TagValue
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
        
        if ($Name)
        {
            $Uri = "$Baseuri/$Name"
            $ResultResourceGroups = Get-InternalRest -Uri $Uri -ReturnType "Blue.ResourceGroup" -ReturnTypeSingular $true
        }
        Else
        {
            $Uri = $Baseuri
            $ResultResourceGroups = Get-InternalRest -Uri $Uri -ReturnType "Blue.ResourceGroup" -ReturnTypeSingular $false
        }
        
        if ($ResultResourceGroups)
        {
            $ResourceGroups += $ResultResourceGroups
        }    
    }
    End
    {
        if ($Location)
        {
            $ResourceGroups = $ResourceGroups | where {$_.Location -eq $Location}
        }
        
        if ($ResourceGroups.Count -eq 0)
        {
            if ($Name)
            {
                Write-error "Nothing found"
                return
            }
        }
        elseif ($ResourceGroups.Count -eq 1)
        {
            Return $ResourceGroups[0]    
        }
        Else
        {
            Return $ResourceGroups
        }
        
            
    }

    
    
    


	
}