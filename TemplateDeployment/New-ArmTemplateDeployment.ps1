function New-ArmTemplateDeployment
{
    [CmdletBinding()]
	Param (
        [Parameter(Mandatory=$true,ParameterSetName='inputFile')]
        [ValidateScript({Test-Path $_})]
        $InputFile,
        
        [Parameter(Mandatory=$false,ParameterSetName='inputFile')]
        [ValidateScript({Test-Path $_})]
        $InputParamFile, 
        
        [Parameter(Mandatory=$true)]
        $ResourceGroupName, 
        
        [Parameter(Mandatory=$true)]
        $DeploymentName, 
        
        [Parameter()]
        [ValidateSet("Incremental", "Complete")]
        $Mode="Incremental"
	)
    
    
    Begin
    {
        $ApiVersion = "2016-02-01"
        if (!(Test-InternalArmConnection))
        {
            Write-Error "Please use Connect-ArmSubscription"
            break
        }
        $BaseUri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)/resourcegroups"
    }
    
    Process
    {
        $ResourcesBefore = Get-ArmResource -ResourceGroupName $ResourceGroupName
        $Uri = "$BaseUri/$ResourceGroupName/providers/microsoft.resources/deployments/$DeploymentName"
        $Data = "" | Select template, parameters, mode
        $Data.template = get-content $InputFile | convertfrom-json
        $Data.parameters = get-content $InputParamFile | convertfrom-json | select -ExpandProperty Parameters
        $Data.mode = $Mode

        $Data2 = "" | select properties
        $Data2.properties = $Data
        
        $Result = Post-InternalRest -uri $Uri -Data $Data2 -method "Put" -apiversion $ApiVersion

        #Get the status of the whole thing
        $ListOptsUri = "$Uri/operations"
        $DeploymentStatus = Get-InternalRest -Uri $uri -apiversion "2016-02-01"
        $LastDepStatus = ""
        $KnownOperations = @()
        $Counter = 0
        do {
            $DeploymentStatus = Get-internalrest -uri $uri -apiversion "2016-02-01"
            $DepStatus = $DeploymentStatus.properties.provisioningState
            if ($LastDepStatus -ne $Depstatus)
            {
                $LastDepStatus = $DepStatus
                Write-Verbose "Deploymentstatus is $DepStatus"
            }
            $operationstatus = Get-internalrest -uri $ListOptsUri -apiversion "2016-02-01"
            foreach ($Op in $operationstatus.value)
            {
                if ($KnownOperations -notcontains ($op.operationId))
                {
                    $KnownOperations += $op.operationId
                    write-verbose "     Operation added to deployment: $($op.properties.provisioningOperation) $($Op.properties.targetResource.resourceName) ($($Op.properties.targetResource.resourceType)) (Op id: $($op.operationId))"
                }
                
                
            }

            #Start sleeping after a while with a bit of easing back
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
        until ("Failed","Succeeded" -contains $DepStatus)
        $OutHash = @{}
        if ($DeploymentStatus.properties.outputs)
        {
            $out = $DeploymentStatus.properties.outputs
            $OutNames = $out | get-member -MemberType NoteProperty | select -ExpandProperty Name
            foreach ($outname in $outnames)
            {
                $OutHash.Add($OutName,$DeploymentStatus.properties.outputs.$outname.value)
            }

            
        }
        
        $Resources = @()  
        $ResourcesAfter = Get-ArmResource -ResourceGroupName $ResourceGroupName
        $UpdatedOrNotChanged = @()
        $Created = @()
        $Deleted = @()
        Foreach ($Resource in $ResourcesAfter)
        {
            if ($ResourcesBefore | where {$_.Name -eq $Resource.Name})
            {
                #Already existed
                $UpdatedOrNotChanged += $resource
            }
            Else
            {
                $Created += $Resource
            }
        }
        Foreach ($Resource in $ResourcesBefore)
        {
            if ($ResourcesAfter | where {$_.Name -eq $Resource.Name})
            {
                #Not deleted
            }
            Else
            {
                $Deleted += $Resource
            }
        }

        Write-Verbose "Number of resources Updated or without change: $($UpdatedOrNotChanged.count)"
        Write-Verbose "Number of resources Created: $($Created.count)"
        Write-Verbose "Number of resources Deleted: $($Deleted.count)"


        <#      
        foreach ($provider in $DeploymentStatus.Properties.providers)
        {
            $resTypes = $Provider.ResourceTypes
            foreach ($restype in $restypes)
            {
                $Resources += $resType
            }
        }
        start-sleep -Seconds 1
        do {
            $operationstatus = Get-internalrest -uri $ListOptsUri -apiversion "2016-02-01"
        }
        until ($OperationStatus.Value.Count -gt $Resources.count)


        $operationstatus = Get-internalrest -uri $ListOptsUri -apiversion "2016-02-01"
        Write-Verbose "Template Operations:"
        $Operations = @()
        foreach ($Op in $operationstatus.value)
        {
            $operations += $op.operationId
            write-verbose "$($Op.properties.targetResource.resourceName) ($($Op.properties.targetResource.resourceType)): $($op.properties.provisioningOperation)"
        }
        #>
        <#
        Do 
        {
            $OperationStatus = Get-internalrest -uri $ListOptsUri -apiversion "2016-02-01"
        }
        until ($true)
        
        

        
        

        $StatusResult = $statusResults[0]

        $state = $statusResult.value.properties.provisioningstate
        $StatusCode = $statusResult.value.properties.provisioningstate

        Do {
            $VeryBaseUri = "https://management.azure.com"
            $DeploymentOperationUri = "$VeryBaseUri$($statusResult.value.id)"
            $StatusResult = Get-InternalRest -Uri $ListOptsUri -apiversion "2016-02-01"
            $state = $statusresult.properties.provisioningstate

        }
        until ($State -eq "Succeeded")
        #>

        


    }
    End
    {
        if ($OutHash)
        {
            $OutHash
        }
    }
}