Function Remove-ArmResourceGroup
{
    [cmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')] 
	Param (
        [Parameter(Mandatory=$true,ParameterSetName='ByObj',ValueFromPipeline=$true)]
        [Blue.ResourceGroup]$InputObject,
        
        [Parameter(Mandatory=$true,ParameterSetName='ByName', Position=0)]
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
        
        #Make sure the thing exists
        $RG = Get-ArmResourceGroup -Name $Name -ErrorAction SilentlyContinue
        if (!$Rg)
        {
            Write-error "Resource Group $Name not found"
            Return
        }
        
        $ContainedResources  =  Get-ArmResource -ResourceGroupName $Name -ErrorAction SilentlyContinue
        
        if ($ContainedResources)
        {
            $ProcessText  = "Remove resource group $Name, along with $($ContainedResources.Count.Tostring()) contained resources"
        }
        Else
        {
            $ProcessText  = "Remove resource group $Name, which is empty"
        }
        
        $Uri = "$Baseuri/$Name"
        if($PSCmdlet.ShouldProcess($script:CurrentSubscriptionId,$ProcessText))
        {
            
            $Result = Get-InternalRest -Uri $Uri -method "Delete" -ReturnFull $true  -apiversion "2015-01-01"
            
            #The "Location" Header of the returned object is the URL to poll in order to check for deletion status
            #The status code returned when hitting that URL will change from 202 to 200 when the operation has completed
            $OperationUri = $Result.Headers.Location
            if ($async -eq $true)
            {
                #We don't care what happened after we asked to delete it
                Write-Verbose "Deletion request successfully sent"
            }
            Else
            {
                #Poll the operationuri to wait for the thing to complete
                Wait-InternalArmOperation -Uri $OperationUri -apiversion "2015-01-01"
            }
            
        }
        
    }
    End
    {
            
    }

}