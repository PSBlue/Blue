Function Get-ArmResourceGroup
{
    [CmdletBinding(DefaultParameterSetName='ByName')]
	Param (
        [Parameter(Mandatory=$true,ParameterSetName='ByObj',ValueFromPipeline=$true)]
        [Blue.ResourceGroup]$InputObject,
        
        [Parameter(Mandatory=$false,ParameterSetName='ByName',Position=0)]
        [Alias("Name")]
        [String]$ResourceGroupName,
        
        [Parameter(Mandatory=$true,ParameterSetName='ByResourceId',Position=0)]
        [String]$ResourceId,
        
        [Parameter(Mandatory=$true,ParameterSetName='ByResourceObj',ValueFromPipeline=$true)]
        [Blue.Resource]$Resource,
        
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
            $ResourceGroupName = $InputObject.ResourceGroupName
        }
        
        if ($Resource)
        {
            $ResourceId = $Resource.ResourceId
        }
        
        if ($ResourceId)
        {
            #Calculate resource group from resourceid
            if ($ResourceId.StartsWith("/"))
            {
                $ResourceId = $ResourceId.Remove(0,1).ToLower()
                $ResourceIdAr = $ResourceId.Split("/")
                $RgIndex = [array]::indexof($ResourceIdAr,"resourcegroups")
                $rgindex ++
                $ResourceGroupName = $ResourceIdAr[$rgindex]
            }
        }
        
        if ($ResourceGroupName)
        {
            $Uri = "$Baseuri/$ResourceGroupName"
            #ResourceGroupName is specified, so we assume a single item
            $ResultResourceGroups = Get-InternalRest -Uri $Uri -ReturnType "Blue.ResourceGroup" -ReturnTypeSingular $true -apiversion "2015-01-01"
        }
        Else
        {
            $Uri = $Baseuri
            #ResourceGroupName is not specified, so we assume multiple items returned.
            $ResultResourceGroups = Get-InternalRest -Uri $Uri -ReturnType "Blue.ResourceGroup" -ReturnTypeSingular $false -apiversion "2015-01-01"
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
            if ($ResourceGroupName)
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