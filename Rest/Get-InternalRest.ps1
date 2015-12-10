Function Get-InternalRest
{
	Param (
		$Uri,
		$BearerToken,
		$ApiVersion,
        $QueryStrings
	)
	
	$ApiVersions = Get-Content (Join-Path $Script:ThisModulePath "Config\Apiversions.json") -Raw| convertfrom-Json
	
	if ($ApiVersion -eq $null)
	{
        $ThisApiVersion = @()
		$ThisApiVersion += $ApiVersions |where {$Uri -match $_.Uri}
		if ($ThisApiVersion.count -ne 1)
		{
			Write-error "zero or multiple api versions found for url $uri"
			Return
		}
		Else
		{
			$ApiVersion = $ThisApiVersion."api-version"
		}
	}
	
	
	if ($BearerToken -eq $null)
	{
		$BearerToken = $script:AuthToken
		#TODO Make sure we're within the timing period of the Access Token
		$TokenExpiry = $script:TokenExpirationUtc
		
	}

    $headers = @{
            "Authorization"="Bearer $BearerToken"
            "Content-Type"="application/json"
        }

    #$ApiVersionQuery = "api-version=$apiversion"

    #Build a hashtable for all querystrings
    if ($QueryStrings)
    {
        $QueryStrings.Add("api-version",$apiversion)
    }
    Else
    {
        $QueryStrings = @{
            "api-version"=$apiversion
        }
    }
    
    Foreach ($Key in $QueryStrings.Keys)
    {
        $ThisValue = $QueryStrings.$key

        $ThisKeyString = "$Key=$ThisValue"

        [System.UriBuilder]$ThisUriBuilder = $uri
        
        if (($ThisUriBuilder.Query -ne $null) -and ($ThisUriBuilder.Query.Length -gt 0))
        {
            $ThisUriBuilder.Query = $ThisUriBuilder.Query.Substring(1) + "&" + $ThisKeyString
        }
        Else
        {
             $ThisUriBuilder.Query = $ThisKeyString
        }

        $Uri = $ThisUriBuilder.ToString()
	
    }

    

    Try
    {
        $Result = Invoke-RestMethod -Method Get -Uri $Uri -Headers $headers
    }
    Catch
    {}

    if ($result)
    {
        return $Result
    }
    Else
    {

    }
	
}