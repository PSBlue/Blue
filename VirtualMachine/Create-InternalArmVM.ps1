Function Create-InternalArmVM
{
    Param (
        $VMName,
        $ResourceGroup,
        $Location,
        $VMSize,
        $VMImage,
        $StorageAccount,
        $StorageAccountContainer,
        $AdminUserName,
        $AdminPassword,
        $OsType,
        $NetworkInterfaceId
        
    )
    
    $CreateVM = New-Object -TypeName Blue.VirtualMachineCreate
    $CreateVM.Id = "$($resourcegroup.id)/providers/Microsoft.Compute/virtualMachines/$VMName"
    $CreateVM.Name = $VMName
    $CreateVM.Location = $Location
    
    #Properties
    $CreateVMProperties = new-object -TypeName Blue.VMProperties
    $CreateVM.Properties = $CreateVMProperties

    #Properties:HardwareProfile
    $CreateVmHW = new-object Blue.HardwareProfile
    $CreateVM.Properties.HardwareProfile = $CreateVmHW
    $CreateVM.Properties.HardwareProfile.VmSize = $VMSize

    #Properties:StorageProfile
    $CreateVMStorageProfile = new-object Blue.StorageProfile
    $CreateVM.Properties.StorageProfile = $CreateVMStorageProfile

    #Properties:StorageProfile.ImageRef
    $CreateVMImageRef = New-Object Blue.ImageReference
    $CreateVm.Properties.StorageProfile.ImageReference = $CreateVMImageRef
    $CreateVm.Properties.StorageProfile.ImageReference.Offer = $VMImage.Offer
    $CreateVm.Properties.StorageProfile.ImageReference.Publisher = $VMImage.Publisher
    $CreateVm.Properties.StorageProfile.ImageReference.Sku = $VMImage.sku
    $CreateVm.Properties.StorageProfile.ImageReference.Version = $VMImage.Version

    #Properties:StorageProfile:OsDisk
    $CreateVmOsDisk = New-Object Blue.OsDisk
    $CreateVm.Properties.StorageProfile.OsDisk = $CreateVmOsDisk
    $CreateVm.Properties.StorageProfile.OsDisk.CreateOption = "FromImage"
    $CreateVm.Properties.StorageProfile.OsDisk.Caching = "ReadWrite"
    
    ##Properties:StorageProfile:OsDisk:Vhd
    $CreateVMVhd = new-object Blue.Vhd
    $CreateVm.Properties.StorageProfile.OsDisk.Vhd = $CreateVMVhd
    $CreateVm.Properties.StorageProfile.OsDisk.Vhd.Uri = "https://$StorageAccount/$StorageAccountContainer/$VMName-OS.vhd"
    
    ##Properties:StorageProfile:OsProfile
    $CreateVmOsProfile = new-object Blue.OsProfile
    $Createvm.Properties.OsProfile = $CreateVmOsProfile
    $Createvm.Properties.OsProfile.adminPassword = $AdminPassword
    $Createvm.Properties.OsProfile.AdminUsername = $AdminUserName
    $Createvm.Properties.OsProfile.ComputerName = $VMName
    
    if ($OsType -eq "Windows")
    {
        $WindowsConfig = new-object Blue.WindowsConfiguration
        $CreateVM.Properties.OsProfile.WindowsConfiguration = $WindowsConfig
        $WindowsConfig.enableAutomaticUpdates = $true
    
    }
    Elseif ($OsType -eq "Linux")
    {
        $linuxconfig = new-object Blue.LinuxConfiguration
        $CreateVM.Properties.OsProfile.LinuxConfiguration = $linuxconfig
        $linuxconfig.DisablePasswordAuthentication = $false
    
    }

    ##Properties:Networkprofile
    $NetworkProfile = new-object Blue.NetworkProfile
    $CreateVM.Properties.NetworkProfile = $NetworkProfile
    
    ##Properties:Networkprofile:Networkinterfaces
    $Nic0 = New-Object Blue.NetworkInterfaceReference
    $CreateVM.Properties.NetworkProfile.NetworkInterfaces = $nic0
    $CreateVM.Properties.NetworkProfile.NetworkInterfaces[0].Id = $NetworkInterfaceId

    $CreateVM
}
