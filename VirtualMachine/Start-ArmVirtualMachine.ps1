Function Start-ArmVirtualMachine
{
    Param (
        [Parameter(Mandatory=$False,ParameterSetName='ByObject',ValueFromPipeline=$true)]
        [Blue.VirtualMachine]$InputObject,
        
        [Switch]$Async
    )
    
    Begin
    {
        #This is the basic test we do to ensure we have a valid connection to Azure
        if (!(Test-InternalArmConnection))
        {
            Write-Error "Please use Connect-ArmSubscription"
            return
        }
        
        $ApiVersion = "2015-06-15"
        $StartOperationUrls = @()   
    }
    Process
    {
        $vm = $InputObject | Get-armvirtualmachine -erroraction SilentlyContinue
        if (!$vm)
        {
            Write-error "Could not find vm $($vm.id)"
            return
        }
        
        $Uri = "https://management.azure.com$($Vm.Id)/Start"
        $Result = Post-InternalRest -Uri $Uri -method "Post" -ProviderName "Microsoft.Compute" -ApiVersion $apiversion -ReturnFull $true
        
        $OperationUri = $Result.Headers.Location
        $StartOperationUrls += $OperationUri
        
    }
    end
    {
        if ($async -eq $true)
        {
            #We don't care what happened after we asked to delete it
            Write-Verbose "Start request successfully sent"
        }
        Else
        {
            #Poll the operationuri to wait for the thing to complete
            Wait-InternalArmOperation -Uri $StopOperationUrls -apiversion $apiversion
        }
    }
}