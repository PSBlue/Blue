Function Get-ArmVirtualMachine
{
    [CmdletBinding(DefaultParameterSetName='ByNothing')]
    Param (
        [Parameter(Mandatory=$True,ParameterSetName='ByName',ValueFromPipeline=$false)]
        [Parameter(Mandatory=$False,ParameterSetName='ByNameAndResourceGroupId',ValueFromPipeline=$false)]
        [Parameter(Mandatory=$False,ParameterSetName='ByNameAndResourceGroupName',ValueFromPipeline=$false)]
        [String]$Name,
        
        [Parameter(Mandatory=$True,ParameterSetName='ByNameAndResourceGroupName',ValueFromPipeline=$false)] 
        [String]$ResourceGroupName,
        
        [Parameter(Mandatory=$True,ParameterSetName='ByNameAndResourceGroupId',ValueFromPipelineByPropertyName=$true)]
        [String]$ResourceGroupId,
        
        [Parameter(Mandatory=$true,ParameterSetName='ByObj',ValueFromPipeline=$true)]
        [Blue.VirtualMachine]$InputObject,
        
        [ValidateSet("Running","Deallocating","Deallocated","Starting")]
        [String]$PowerState
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
            if ($ResourceGroupName)
            {
                $Uri = "$Uri$Name/"    
            }
            Else
            {
                $PostFilterName = $true
            }
            
        }
        
        if ($InputObject)
        {
            $Name = $InputObject.Name
        }
        
        
        $UriParams = @{}
        $UriParams.Add("Uri",$Uri)
        $UriParams.Add("ReturnType","Blue.VirtualMachine")
        $UriParams.Add("ProviderName","Microsoft.Compute")
        
        if ($Name -and $ResourceGroupName)
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
        foreach ($vm in $VirtualMachines)
        {
            
            $Uri = "https://management.azure.com$($vm.id)/InstanceView"
            $UriParams = @{}
            $UriParams.Add("Uri",$Uri)
            $UriParams.Add("ReturnType","Blue.VMInstanceView")
            $UriParams.Add("ProviderName","Microsoft.Compute")
            $ResultInstanceView = Get-InternalRest @UriParams -ReturnTypeSingular $true
            $Vm.InstanceView = $ResultInstanceView
            $ResultInstanceView = $null
            $vm.VirtualMachineId = $vm.Id
            $vm.PowerState = ($vm.InstanceView.statuses | where {$_.Code -match "powerstate"} | select -ExpandProperty code).Split("/")[1]
            $vm.ProvisioningState = ($vm.InstanceView.statuses | where {$_.Code -match "ProvisioningState"} | select -ExpandProperty code).Split("/")[1]
        }
        
        if ($PowerState)
        {
            $Virtualmachines = $Virtualmachines | where {$_.PowerState -eq $PowerState}
        }
        
        if ($PostFilterName -eq $true)
        {
            #Name was specified without RG, do client-side filter before returning the thing.
            if ($VirtualMachines.count -gt 20)
            {
                Write-verbose "In order to speed up execution, it is recommended that you also specify the resource group when getting a specific vm in a subscription with many vms. Your current parameters forced us to search all $($VirtualMachines.count) vms in the current subscription."
            }
            $VirtualMachines = $VirtualMachines | where {$_.Name -eq $Name}
        }
        
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