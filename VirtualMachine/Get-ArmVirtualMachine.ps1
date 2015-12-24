Function Get-ArmVirtualMachine
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
        
        [Parameter(Mandatory=$true,ParameterSetName='ByObj',ValueFromPipeline=$true)]
        [Blue.VirtualMachine]$InputObject
    )
    Begin
    {
        #This is the basic test we do to ensure we have a valid connection to Azure
        if (!(Test-InternalArmConnection))
        {
            Write-Error "Please use Connect-ArmSubscription"
            return
        }
    
        $VirtualMachines = @()   
    }
    Process
    {
        if ($ResourceGroupId)
        {
            $ResourceGroupName = Get-ArmResourceGroup | where {$_.ResourceGroupId -eq $ResourceGroupId} | Select -ExpandProperty Name
        }
        if ($ResourceGroupName)
        {
            $Uri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/virtualMachines/"    
        }
        Elseif ($InputObject)
        {
            $Uri = "https://management.azure.com$($InputObject.Id)/"
        }
        Else
        {
            $Uri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)/providers/Microsoft.Compute/virtualMachines/"
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
        $UriParams.Add("ReturnType","Blue.VirtualMachine")
        $UriParams.Add("ProviderName","Microsoft.Compute")
        
        if ($Name)
        {
            $ResultVirtualMachines = Get-InternalRest @UriParams -ReturnTypeSingular $true
        }
        Else
        {
            $ResultVirtualMachines = Get-InternalRest @UriParams -ReturnTypeSingular $false    
        }
        
        $VirtualMachines += $ResultVirtualMachines
        
    }
    End
    {
        if (($VirtualMachines.Count -eq 0) -and ($Name))
        {
            Write-Error "VM $Name not found"    
        }
        ElseIf ($VirtualMachines.count -eq 1)
        {
            return $VirtualMachines[0]
        }
        Else
        {
            return $VirtualMachines
        }
        
        
    }
    
    
}