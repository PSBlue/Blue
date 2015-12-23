Function Get-ArmVirtualMachine
{
    Begin
    {
        #This is the basic test we do to ensure we have a valid connection to Azure
        if (!(Test-InternalArmConnection))
        {
            Write-Error "Please use Connect-ArmSubscription"
            return
        }
    
        $Uri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)/resourceGroups/AnsibleStuff/providers/Microsoft.Compute/virtualMachines" 
        
        $VirtualMachines = @()   
    }
    Process
    {
        $ResultVirtualMachines = Get-InternalRest -Uri $Uri -ReturnType "Blue.VirtualMachine" -ReturnTypeSingular $false
    }
    End
    {
        $ResultVirtualMachines
    }
    
}