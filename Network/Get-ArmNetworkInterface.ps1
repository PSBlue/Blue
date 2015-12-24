Function Get-ArmNetworkInterface
{
    [CmdletBinding(DefaultParameterSetName='ByNothing')]
    Param (
        [Parameter(Mandatory=$False,ParameterSetName='ByNameAndResourceGroupId',ValueFromPipeline=$false)]
        [Parameter(Mandatory=$False,ParameterSetName='ByNameAndResourceGroupName',ValueFromPipeline=$false)]
        [String]$Name,
        
        [Parameter(Mandatory=$True,ParameterSetName='ByNameAndResourceGroupName',ValueFromPipeline=$false)] 
        [String]$ResourceGroupName,
        
        [Parameter(Mandatory=$True,ParameterSetName='ByNameAndResourceGroupId',ValueFromPipelineByPropertyName=$true)]
        [String]$ResourceGroupId,
        
        [Parameter(Mandatory=$True,ParameterSetName='ByVm',ValueFromPipelineByPropertyName=$true)]
        [String]$VirtualMachineId,
        
        [Parameter(Mandatory=$true,ParameterSetName='ByObj',ValueFromPipeline=$true)]
        [Blue.NetworkInterface]$InputObject
    )
    Begin
    {
        #This is the basic test we do to ensure we have a valid connection to Azure
        if (!(Test-InternalArmConnection))
        {
            Write-Error "Please use Connect-ArmSubscription"
            return
        }
        $QueryNics=@()
        $Nics = @()   
    }
    Process
    {
        if ($VirtualMachineId)
        {
            $VM = Get-ArmVirtualMachine | where {$_.VirtualMachineId -eq $VirtualMachineId}
            Write-verbose "Lising NICs for vm $($VM.Name)"
            $VMNics = $vm.Properties.NetworkProfile.NetworkInterfaces
            foreach ($Nic in $VMNics)
            {
                $UriObj = "" | Select Uri, Singular
                $UriObj.Singular = $true
                $UriObj.Uri = "https://management.azure.com$($Nic.Id)"
                $QueryNics += $UriObj;$uriObj = $null
            }
        }
        Elseif ($ResourceGroupId)
        {
            $ResourceGroupName = Get-ArmResourceGroup | where {$_.ResourceGroupId -eq $ResourceGroupId} | Select -ExpandProperty Name
        }
        if ($ResourceGroupName)
        {
            $Uri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)/resourceGroups/$ResourceGroupName/providers/Microsoft.Network/networkinterfaces/"    
        }
        Elseif ($InputObject)
        {
            $Uri = "https://management.azure.com$($InputObject.Id)/"
        }
        Elseif (!$VirtualMachineId)
        {
            $Uri = "https://management.azure.com/subscriptions/$($script:CurrentSubscriptionId)/providers/Microsoft.Network/networkinterfaces/"
        }
         
        
        if ($Name)
        {
            $Uri = "$Uri$Name/"
        }
        
        if ($InputObject)
        {
            $Name = $InputObject.Name
        }
        
        
        if ($uri)
        {
            $UriObj = "" | Select Uri, Singular
            $Uriobj.Uri = $uri
            if ($Name)
            {
                $UriObj.Singular = $true
            }
            Else
            {
                $UriObj.Singular = $false
            }
            $QueryNics += $Uriobj;$uriobj= $null
        }
        
        
        
        foreach ($Nic in $QueryNics)
        {
            $UriParams = @{}
            $UriParams.Add("Uri",$Nic.Uri)
            $UriParams.Add("ReturnType","Blue.NetworkInterface")
            $UriParams.Add("ProviderName","Microsoft.Network")
            $UriParams.Add("ReturnTypeSingular",$Nic.Singular)
            
            $ResultNics = Get-InternalRest @UriParams
            $Nics += $ResultNics;$ResultNics = $null
            
        }
        
        
    }
    End
    {
        if (($Nics.Count -eq 0) -and ($Name))
        {
            Write-Error "Network Interface $Name not found"    
        }
        ElseIf ($Nics.count -eq 1)
        {
            return $Nics[0]
        }
        Else
        {
            return $Nics
        }
        
        
    }
    
    
}