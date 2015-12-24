Function Get-ArmVirtualNetwork
{
    [CmdletBinding(DefaultParameterSetName='ByNothing')]
    Param (
        [Parameter(Mandatory=$False,ParameterSetName='ByNameAndResourceGroupId',ValueFromPipeline=$false)]
        [Parameter(Mandatory=$False,ParameterSetName='ByNameAndResourceGroupName',ValueFromPipeline=$false)]
        [String]$Name,
        
        [Parameter(Mandatory=$True,ParameterSetName='ByNameAndResourceGroupName',ValueFromPipeline=$false)] 
        [String]$ResourceGroupName,
        
        [Parameter(Mandatory=$True,ParameterSetName='ByNameAndResourceGroupId',ValueFromPipelineByPropertyName=$true)]
        [String]$ResourceGroupId,
        
        [Parameter(Mandatory=$True,ParameterSetName='BySubnetId',ValueFromPipelineByPropertyName=$true)]
        [String]$SubnetId,
        
        [Parameter(Mandatory=$true,ParameterSetName='ByObj',ValueFromPipeline=$true)]
        [Blue.VirtualNetwork]$InputObject
    )
    Begin
    {
        #This is the basic test we do to ensure we have a valid connection to Azure
        if (!(Test-InternalArmConnection))
        {
            Write-Error "Please use Connect-ArmSubscription"
            return
        }
    
        $VirtualNetworks = @()   
    }
    Process
    {
        if ($ResourceGroupId)
        {
            $ResourceGroupName = Get-ArmResourceGroup | where {$_.ResourceGroupId -eq $ResourceGroupId} | Select -ExpandProperty Name
        }
        if ($ResourceGroupName)
        {
            $Uri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)/resourceGroups/$ResourceGroupName/providers/Microsoft.Network/virtualnetworks/"    
        }
        Elseif ($InputObject)
        {
            $Uri = "https://management.azure.com$($InputObject.Id)/"
        }
        ElseIf ($SubnetId)
        {
            $Uri = "https://management.azure.com$SubnetId/"
            #Get rid of the subnet / subnetname segments
            $UriObj = New-Object -TypeName "System.uri" -ArgumentList $Uri
            $UnneededSegments = $UriObj.Segments[9..999]
            $StrUnneededSegments = $UnneededSegments -join ""
            $Uri = $uri.Replace($StrUnneededSegments,"")
        }
        Else
        {
            $Uri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)/providers/Microsoft.Network/virtualnetworks/"
        }
         
        
        if ($Name)
        {
            $Uri = "$Uri$Name/"
        }
        
        if ($InputObject)
        {
            $Name = $InputObject.Name
        }
        
        
        $UriParams = @{}
        $UriParams.Add("Uri",$Uri)
        $UriParams.Add("ReturnType","Blue.VirtualNetwork")
        $UriParams.Add("ProviderName","Microsoft.Network")
        
        if ($Name -or $SubnetId)
        {
            $ResultVnets = Get-InternalRest @UriParams -ReturnTypeSingular $true
        }
        Else
        {
            $ResultVnets = Get-InternalRest @UriParams -ReturnTypeSingular $false    
        }
        
        $VirtualNetworks += $ResultVnets
        
    }
    End
    {
        foreach ($vnet in $VirtualNetworks)
        {
            $vnet.VirtualNetworkId = $vnet.Id
        }
        
        if (($VirtualNetworks.Count -eq 0) -and ($Name))
        {
            Write-Error "Virtual Network $Name not found"    
        }
        ElseIf ($VirtualNetworks.count -eq 1)
        {
            return $VirtualNetworks[0]
        }
        Else
        {
            return $VirtualNetworks
        }
        
        
    }
    
    
}