Function Get-ArmResourceGroup
{
    [CmdletBinding(DefaultParameterSetName='ByName')]
	Param (
        [Parameter(Mandatory=$true,ParameterSetName='ByObj',ValueFromPipeline=$true)]
        [Blue.ResourceGroup]$InputObject,
        
        [Parameter(Mandatory=$false,ParameterSetName='ByName',Position=0)]
        [String]$Name,
        
        [Parameter(Mandatory=$false,ParameterSetName='ByName',Position=1)]
        [String]$Location,
        
        [Parameter(Mandatory=$false,ParameterSetName='ByName')]
		[String]$TagName,
        
        [Parameter(Mandatory=$false,ParameterSetName='ByName')]
        [String]$TagValue
	)
    
    Begin
    {
        #This is the basic test we do to ensure we have a valid connection to Azure
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
            #Name is specified, so we assume a single item
            $ResultResourceGroups = Get-InternalRest -Uri $Uri -ReturnType "Blue.ResourceGroup" -ReturnTypeSingular $true
        }
        Else
        {
            $Uri = $Baseuri
            #Name is not specified, so we assume multiple items returned.
            $ResultResourceGroups = Get-InternalRest -Uri $Uri -ReturnType "Blue.ResourceGroup" -ReturnTypeSingular $false
        }
        
        if ($ResultResourceGroups)
        {
            $ResourceGroups += $ResultResourceGroups
        }    
    }
    End
    {
        #Fill the ResourceGroupId Attribute
        foreach ($rg in $ResourceGroups)
        {
            $rg.ResourceGroupId = $rg.id
        }
        
        #Filter by location if specified
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
            #If only a single RG, return that instead of the array
            Return $ResourceGroups[0]    
        }
        Else
        {
            Return $ResourceGroups
        }
        
            
    }

    
    
    


	
}