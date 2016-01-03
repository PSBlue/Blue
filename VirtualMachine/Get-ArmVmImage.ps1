<#
.Synopsis
   Gets a list of available VM Images
.DESCRIPTION
   Lists available VM images in Azure.
.EXAMPLE
   Get-ArmVmImage -Location "westeurope" -Publisher "Canonical"
.EXAMPLE
   Get-ArmVmImage -Location "us" -Publisher "windows"
.INPUTS
   
.OUTPUTS
   A list of generic objects representing vm images.
.NOTES
   All parameters are optional and "wildcarded". This means that location "us" will search for images in all locations containing "us".
   However, the more narrow the search, the faster the query will run.
   This function does not query Azure directly, but a separate index of all images. This index is refreshed every 6 hours, which means that 
   brand new images might not show up in results.
#>
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