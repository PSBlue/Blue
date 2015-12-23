Function Remove-ArmResourceGroup
{
    [cmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')] 
	Param (
        [Parameter(Mandatory=$true,ParameterSetName='ByObj',ValueFromPipeline=$true)]
        [Blue.ResourceGroup]$InputObject,
        
        [Parameter(Mandatory=$true,ParameterSetName='ByName')]
        [String]$Name,
        [Switch]$Async
	)
    
    Begin
    {
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
            $Name = $InputObject.Name
        }
        
        
        $Uri = "$Baseuri/$Name"
        if($PSCmdlet.ShouldProcess($script:CurrentSubscriptionId,"Remove resource group $Name"))
        {
            
            $Result = Get-InternalRest -Uri $Uri -method "Delete" -ReturnFull $true 
            $OperationUri = $Result.Headers.Location
            if ($async -eq $true)
            {
                Write-Verbose "Deletion request successfully sent"
            }
            Else
            {
                Wait-ArmOperation -Uri $OperationUri
            }
            
        }
        
    }
    End
    {
            
    }

}