Function Get-ArmSubnet
{
    [CmdletBinding(DefaultParameterSetName='ByNameAndVirtualNetworkObject')]
    Param (
        [Parameter(Mandatory=$False,ParameterSetName='ByNameAndVirtualNetworkObject',ValueFromPipeline=$false)]
        [String]$Name,
        
        [Parameter(Mandatory=$True,ParameterSetName='ByNameAndVirtualNetworkObject',ValueFromPipeline=$True)]
        [Blue.VirtualNetwork]$VirtualNetwork,
        
        [Parameter(Mandatory=$True,ParameterSetName='BySubnetId',ValueFromPipeline=$True)]
        [String]$SubnetId
    )
    
    Begin
    {
        #This is the basic test we do to ensure we have a valid connection to Azure
        if (!(Test-InternalArmConnection))
        {
            Write-Error "Please use Connect-ArmSubscription"
            return
        }
    
        $Subnets = @()   
    }
    Process
    {
        if ($VirtualNetwork)
        {
            $uri = "https://management.azure.com$($vnet.VirtualNetworkId)/subnets"
        }
        if ($Name)
        {
            $uri = "$uri/$name"
        }
        
        if ($SubnetId)
        {
            $Uri = "https://management.azure.com$($SubnetId)"
        }
        $UriParams = @{}
        $UriParams.Add("Uri",$Uri)
        $UriParams.Add("ReturnType","Blue.Subnet")
        $UriParams.Add("ProviderName","Microsoft.Network")
        
        if (($Name) -or ($SubnetId))
        {
            $ResultSubnets = Get-InternalRest @UriParams -ReturnTypeSingular $true
        }
        Else
        {
            $ResultSubnets = Get-InternalRest @UriParams -ReturnTypeSingular $false
        }
        
        $Subnets += $ResultSubnets
        
    }
    end
    {
        foreach ($Subnet in $Subnets)
        {
            $Subnet.SubnetId = $Subnet.Id
        }
        
        if (($Subnets.Count -eq 0) -and ($Name))
        {
            Write-error "Subnet $Name not found"
        }
        ElseIf ($Subnets.Count -eq 1)
        {
            return $Subnets[0]
        }
        Else
        {
            return $subnets
        }
            
    }
    
    
    
}