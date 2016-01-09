Function Stop-ArmVirtualMachine
{
    Param (
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
        
    }
}