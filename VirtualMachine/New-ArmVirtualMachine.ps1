Function New-ArmVirtualMachine
{
    [CmdletBinding(DefaultParameterSetName='ByNameAndResourceGroupName')]
    Param (
        # Name of the VM to create
        [Parameter(Mandatory=$True,ParameterSetName='ByNameAndResourceGroupName',ValueFromPipeline=$false)]
        [Parameter(Mandatory=$True,ParameterSetName='ByNameAndResourceGroupId',ValueFromPipeline=$false)]
        $VMName,
        
        # Location if the VM. If omitted, the location of the Resource Group is used
        [Parameter(Mandatory=$False,ValueFromPipeline=$false)]
        $Location,
        
        # The virtual network to place the VM in (either vnet object or vnet name)
        [Parameter(Mandatory=$False,ValueFromPipeline=$false)]
        $Vnet,
        
        # The subnet to place the VM in (either subnet object or subnet name)
        [Parameter(Mandatory=$False,ValueFromPipeline=$false)]
        $Subnet,
        
        [Parameter(Mandatory=$True,ParameterSetName='ByNameAndResourceGroupName',ValueFromPipeline=$false)]
        [Parameter(Mandatory=$True,ParameterSetName='ByInstanceCountAndResourceGroupName',ValueFromPipeline=$false)]
        $ResourceGroupName,
        
        [Parameter(Mandatory=$True,ParameterSetName='ByNameAndResourceGroupId',ValueFromPipelineByPropertyName=$true)]
        [Parameter(Mandatory=$True,ParameterSetName='ByInstanceCountAndResourceGroupId',ValueFromPipelineByPropertyName=$true)]
        $ResourceGroupId,
        
        [Parameter(Mandatory=$True,ParameterSetName='ByInstanceCountAndResourceGroupName',ValueFromPipeline=$false)]
        [Parameter(Mandatory=$True,ParameterSetName='ByInstanceCountAndResourceGroupId',ValueFromPipeline=$false)]
        [int]$InstanceCount,
        
        [Parameter(Mandatory=$False,ParameterSetName='ByInstanceCountAndResourceGroupName',ValueFromPipeline=$false)]
        [Parameter(Mandatory=$False,ParameterSetName='ByInstanceCountAndResourceGroupId',ValueFromPipeline=$false)]
        $NamePattern="###-****",
        
        
        [Parameter(Mandatory=$False,ValueFromPipeline=$false)]
        $StorageAccountName,
        
        # Is Async is specified, the shell returns immediately, not waiting for the VM to be created. 
        [Switch]$Async
    )
    
    Begin
    {}
    Process
    {
        if ($ResourceGroupId)
        {
            $ResourceGroup = Get-ArmResourceGroup | where {$_.ResourceGroupId -eq $ResourceGroupId}
        }
        ElseIf ($ResourceGroupName)
        {
            $ResourceGroup = Get-ArmResourceGroup -Name $ResourceGroupName
        }
        
        if (!$ResourceGroup)
        {
            Write-error "Resource Group $Name not found"
            Return
        }
        
        if (!$Location)
        {
            $Location = $ResourceGroup.Location
        }
            
            
        #Figure out if we need to do some calculations
        if (!$Vnet -or !$Subnet -or $StorageAccountName)
        {
            #We don't have all the required info
            $ExistingVMs = $ResourceGroup | Get-ArmVirtualMachine
        }
        
        
        
    }
}