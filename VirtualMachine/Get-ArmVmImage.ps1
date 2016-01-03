Function Get-ArmVmImage
{
    [CmdletBinding()]
    Param(
        $Location,
        $Publisher,
        $Offer,
        $Sku,
        $Version
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
        $QueryStrings = @{}
        if ($Location)
        {
            $QueryStrings.add("Location",$Location)
        }
        
        if ($Publisher)
        {
            $QueryStrings.add("Publisher",$Publisher)
        }
        
        if ($Offer)
        {
            $QueryStrings.add("Offer",$Offer)
        }
        
        if ($Sku)
        {
            $QueryStrings.add("sku", $sku)
        }
        if ($Version)
        {
            $QueryStrings.add("version", $version)
        }
        
        $vmimages = Get-InternalRest -uri $Script:ImageSearchApiUrl -querystrings $QueryStrings -apiversion "2015-06-15"
        foreach ($vmimage in $vmimages)
        {
            $vmimage.id = "/Subscriptions/$($script:CurrentSubscriptionId)/Providers/Microsoft.Compute" + $vmimage.id
        }
        return $vmimages
        
    }
}