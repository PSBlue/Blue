Function Get-ArmVirtualMachine
{
    [CmdletBinding(DefaultParameterSetName='ByNameAndResourceGroupName')]
    Param (
        [Parameter(Mandatory=$False,ParameterSetName='ByNameAndResourceGroupName',ValueFromPipeline=$false)]
        [String]$Name,
        
        [Parameter(Mandatory=$False,ParameterSetName='ByNameAndResourceGroupName',ValueFromPipeline=$false)]
        [String]$ResourceGroupName,
        
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
        if ($ResourceGroupName)
        {
            $Uri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)/resourceGroups/AnsibleStuff/providers/Microsoft.Compute/virtualMachines/"    
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
        
        

        
        if ($Name)
        {
            $ResultVirtualMachines = Get-InternalRest -Uri $Uri -ReturnType "Blue.VirtualMachine" -ReturnTypeSingular $true
        }
        Else
        {
            $ResultVirtualMachines = Get-InternalRest -Uri $Uri -ReturnType "Blue.VirtualMachine" -ReturnTypeSingular $false    
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