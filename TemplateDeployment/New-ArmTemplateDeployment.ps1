function New-ArmTemplateDeployment
{
    [CmdletBinding()]
	Param (
        [Parameter()]
        $InputFile,
        
        [Parameter()]
        $InputParamFile, 
        
        $ResourceGroupName, 
        
        $DeploymentName, 
        
        $Mode
	)
    
    Begin
    {
        if (!(Test-InternalArmConnection))
        {
            Write-Error "Please use Connect-ArmSubscription"
            break
        }
        $BaseUri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)/resourcegroups"
        
    }
    
    Process
    {
        $Uri = "$BaseUri/$ResourceGroupName/providers/microsoft.resources/deployments/$DeploymentName"
        $Data = "" | Select template, parameters, mode
        $Data.template = get-content $InputFile | convertfrom-json
        $Data.parameters = get-content $InputParamFile | convertfrom-json | select -ExpandProperty Parameters
        $Data.mode = $Mode

        $Data2 = "" | select properties
        $Data2.properties = $Data
        
        $Result = Post-InternalRest -uri $Uri -Data $Data2 -method "Put" -apiversion "2016-02-01"

        #List current operations
        $ListOptsUri = "$Uri/operations"

        Do 
        {
            $StatusResult = Get-InternalRest -Uri $ListOptsUri -apiversion "2016-02-01"
        }
        until ($StatusResult.value.count -gt 0)
        
        $state = $statusResult[0].value.properties.provisioningstate
        $StatusCode = $statusResult[0].value.properties.provisioningstate
        
        
    }
    
    
}