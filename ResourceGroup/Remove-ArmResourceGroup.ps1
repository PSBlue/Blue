Function Remove-ArmResourceGroup
{
    [cmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')] 
	Param (
        [Parameter(Mandatory=$true,ParameterSetName='ByObj',ValueFromPipeline=$true)]
        [Blue.ResourceGroup]$InputObject,
        
        [Parameter(Mandatory=$true,ParameterSetName='ByName')]
        [String]$Name
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
            $OperationUrl = $Result.Headers.Location
            $Counter = 1
            $OperationIsFinished = $false
            $OperationStart = Get-Date
            #Loop while waiting until the statuscode turns from 202 (in progress) to 200 (done)
            Do {
                $nowtime = Get-Date
                $ElapsedTime = $nowtime - $OperationStart
                Write-Verbose "Waiting for arm operation (elapsed seconds: $($ElapsedTime.Totalseconds))"
                $OperationResult = Get-InternalRest -Uri $Uri -ReturnFull $true
                if ($OperationResult.StatusCode -eq 200)
                {
                    #Arm Operation done
                    $OperationIsFinished = $true
                }
                ElseIf ($OperationResult.StatusCode -eq 202)
                {
                    #Arm operation Still in progress
                }
                Else
                {
                    #No idea whats going on
                }
                
                #Start sleeping after a while
                if ($counter -gt 5 -and $counter -lt  10)
                {
                    Start-Sleep -Milliseconds 500
                }
                ElseIf ($counter -gt 11 -and $counter -lt  50)
                {
                    Start-Sleep -Seconds 2
                }
                ElseIf ($counter -gt 50 -and $counter -lt  999)
                {
                    Start-Sleep -Seconds 5
                }
                $counter ++
            }
            Until (($OperationIsFinished -eq $true) -or ($Counter -gt 999))
        }
        
            
    }
    End
    {
            
    }

    
    
    


	
}