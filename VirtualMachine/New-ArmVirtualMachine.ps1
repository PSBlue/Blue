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

        [String]$StorageAccountContainer = "vhds",
        
        [String]$VmImage,
        
        [String]$OsType,
        
        
        
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
        if ((!$Vnet) -or (!$Subnet) -or (!$StorageAccountName))
        {
            #We don't have all the required info
            $ExistingVMs = $ResourceGroup | Get-ArmVirtualMachine
            if ($ExistingVMs -eq $null)
            {
                Write-error "No existing VMs in resource group to read properties from."
                return
            }
            
            if ((!$vnet) -or (!$Subnet))
            {
                #Get the vnet
                $Vnets = @()
                Foreach ($VM in $ExistingVMs)
                {
                    $Nics = $vm | Get-ArmNetworkInterface -Verbose:$false
                    foreach ($Nic in $Nics)
                    {
                        if ($nic.Properties.IpConfigurations[0].properties.subnet.id)
                        {
                            $ThisVnet = Get-ArmVirtualNetwork -SubnetId $nic.Properties.IpConfigurations[0].properties.subnet.id
                            if ($ThisVnet)
                            {
                                $Vnets += $ThisVnet.VirtualNetworkId
                            }
                        }
                    }
                }
            }

            if (!$vnet)
            {
                if (($Vnets | select -Unique).count -gt 1)
                    {
                        Write-error "Existing VMs have different virtual networks, so you have to specify the virtual network for the new vm(s)"
                        return
                    }
                    Else
                    {
                        $ThisVnet = Get-ArmVirtualNetwork -VirtualNetworkId ($Vnets | select -Unique)
                        Write-Verbose "Autoselected virtual network $($ThisVnet.Name) based on existing vms in the same resource group"
                    }
            }
            Else
            {
                if ($Vnet.GetType().Name -eq "String")
                {
                    $vnet = Get-ArmVirtualNetwork -VirtualNetworkId $Vnet
                }
            }
            
            

            if (!$subnet)
            {
                $AllSubnets = @()
                if ($vnet.Properties.Subnets.count -eq 1)
                {
                    
                    $Subnet = $vnet.Properties.Subnets[0].Name
                    Write-Verbose "Autoselected subnet $subnet since that's the only one in selected vnet $($vnet.Name)"

                }
                Else
                {
                    $Nics = $ExistingVMs | Get-ArmNetworkInterface -verbose:$False
                    Foreach ($Nic in $Nics)
                    {
                        $SubnetId = $nics[0].Properties.IpConfigurations[0].properties.subnet.id
                        $AllSubnets += $SubnetId
                    }

                    if (($AllSubnets | select -Unique).count -gt 1)
                    {
                        Write-error "Existing VMs have subnets, and the selected virtual network contains more than one, so you have to specify the subnet for the new vm(s)"
                    }
                    Else
                    {
                        $Subnet = $AllSubnets | select -Unique
                        $Subnet = Get-ArmSubnet -subnetId $Subnet
                        #TODO: Build a subnet function thingy
                        Write-Verbose "Autoselected subnet: $($Subnet.Name) based on existing vms in the same resource group"
                    }
                    
                }


            }

            if (!$StorageAccount)
            {
                $AllOsDiskVhdUris = @()
                foreach ($ExistingVM in $ExistingVMs)
                {
                    #Grab the osdisk uri
                    [System.UriBuilder]$VhdUri = $ExistingVM.Properties.StorageProfile.OsDisk.Vhd.uri
                    $VhdStorageAccount = $vhduri.host
                    $AllOsDiskVhdUris += $VhdStorageAccount
                }

                if (($AllOsDiskVhdUris | select -Unique).count -eq 1)
                {
                    $StorageAccount = $AllOsDiskVhdUris | select -Unique
                    Write-Verbose "Autoselected storage account: $StorageAccount based on existing vms in the same resource group"
                }
            }
            
            if (!$Vmimage)
            {
                $AllImages = @()
                foreach ($ExistingVM in $ExistingVMs)
                {
                    #Grab the osdisk uri
                    $ImageRef = $ExistingVM.Properties.StorageProfile.ImageReference
                    $ImageRefString = "/$($ImageRef.Publisher)/$($ImageRef.Offer)/$($ImageRef.Sku)/$($ImageRef.Version)"
                    $AllImages += $ImageRefString
                }
                if (($AllImages | select -Unique).count -eq 1)
                {
                    $VMImage = $AllImages | select -Unique
                    Write-Verbose "Autoselected vm image: $VMImage based on existing vms in the same resource group"
                }
                Else
                {
                    Write-error "Unable to auto-select VMImage, plase specify th VMImage parameter"
                }
                
            }
        }
        
        
        if ($VmImage.Gettype().Name -eq "String")
        {
            if ($vmimage.StartsWith("/"))
            {
                #Get rid of the first slash
                $vmimage = $vmimage.remove(0,1)
            }
            $VmImageParts = $VMImage.split("/")
            $Publisher = $VmImageParts[0]
            $Offer = $VmImageParts[1]
            $Sku = $VmImageParts[2]
            $Version = $vmImageParts[3]
            
            $ImageSearcharams = @{
                "Location"=$Location;
                "Publisher"=$Publisher;
                "Offer"=$Offer;
                "Sku"=$Sku
            }
            if ($version.ToLower() -eq "latest")
            {
                $LatestVersion = $true
            }
            Else
            {
                $ImageSearcharams.Add("version",$Version)
            }
            
        }
        
        if (!$OsType)
        {
            Write-verbose "Looking up vm image"
            $VMImageResultList = Get-ArmVmImage @ImageSearcharams
            if ($LatestVersion)
            {
                Foreach ($ImageResult in $VMImageResultList)
                {
                    #Add some strongly sortable version thingys
                    [System.Version]$ImageVersion = $ImageResult.Version
                    $imageresult | Add-Member -Name "VersionType" -MemberType NoteProperty -Value $ImageVersion -Force
                    
                }
                $SelectedVmImage = $VMImageResultList | sort VersionType -Descending | select -First 1
                Write-verbose "Selected latest image version, which is $($SelectedVmImage.Version)"
            }
            
            $OsType = $SelectedVmImage.properties.osDiskImage.operatingSystem
            Write-Verbose "Selected image has OS type $OsType"    
        }
        
        if (!$InstanceCount)
        {
            $InstanceCount = 1
        }
        Else
        {
            Write-verbose "Generating $InstanceCount VMs"
        }
        
        $VMCreateCounter = 1
        Do
        {
            Write-verbose "Generating vm $VMCreateCounter of $InstanceCount"
            if ($VmName)
            {
                
            }
            Else
            {
                $NameArray = Invoke-InternalStringToArray -InputString $NamePattern
                $RealNameArray = @()
                foreach ($Char in $NameArray)
                {
                    if ($Char -eq "#")
                    {
                        #Generate random char
                        $Random = Get-Random -Minimum 65 -Maximum 90
                        $RandomChar = [char]$Random
                        $RealNameArray += $RandomChar
                    }
                    Elseif ($Char -eq "*")
                    {
                        #Generate random number
                        $Random = get-random -Minimum 1 -Maximum 9
                        $RealNameArray += $Random.ToString()
                    }
                    Else
                    {
                        $RealNameArray += $Char
                    }
                }
                $VMCreateVMName = $RealNameArray -join ""
                Write-Verbose "Generating VM $VMCreateVMName"
            }
            $VMCreateCounter ++
        }
        Until ($VMCreateCounter -gt $InstanceCount)
        
        
        
    }
    end
    {
        
    }
}