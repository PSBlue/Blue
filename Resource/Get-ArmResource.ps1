Function Get-ArmResource
{
    [CmdletBinding()]
	Param (
        [Parameter(Mandatory=$true,ParameterSetName='ByObj',ValueFromPipeline=$true)]
        [Blue.ResourceGroup]$InputObject,
        
        [Parameter(Mandatory=$false,ParameterSetName='ByName')]
        [String]$ResourceGroupName
        
	)
    
    Begin
    {
        if (!(Test-InternalArmConnection))
        {
            Write-Error "Please use Connect-ArmSubscription"
            return
        }
    
        $BaseUri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)" 
        
        $Resources = @()   
    }
    Process
    {
        if ($InputObject)
        {
            $ResourceGroupName = $InputObject.Name
        }
        
        if ($ResourceGroupName)
        {
            $Uri = "$Baseuri/resourcegroups/$ResourceGroupName/Resources"
            $ResultResources = Get-InternalRest -Uri $Uri -ReturnType "Blue.Resource" -ReturnTypeSingular $false -apiversion "2015-01-01"
        }
        Else
        {
            $Uri = "$Baseuri/Resources"
            $ResultResources = Get-InternalRest -Uri $Uri -ReturnType "Blue.Resource" -ReturnTypeSingular $false -apiversion "2015-01-01"
        }
        
        if ($ResultResources)
        {
            $Resources += $ResultResources
        }    
    }
    End
    {
        if ($Resources.Count -eq 0)
        {
            if ($ResourceGroupName)
            {
                Write-error "Nothing found"
                return
            }
        }
        elseif ($Resources.Count -eq 1)
        {
            Return $Resources[0]    
        }
        Else
        {
            Return $Resources
        }
        
            
    }

}