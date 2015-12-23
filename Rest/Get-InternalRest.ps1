Function Get-InternalRest
{
    [CmdletBinding(DefaultParameterSetName='ReturnObject')]
	Param (
		[Parameter(Mandatory=$true)]
        $Uri,
		[Parameter(Mandatory=$false)]
        $BearerToken,
		[Parameter(Mandatory=$false)]
        $ApiVersion,
        [Parameter(Mandatory=$false)]
        $QueryStrings,
        [bool]$ReturnFull=$False,
        [Parameter(Mandatory=$true,ParameterSetName='ReturnStronglyTypedObject')]
        $ReturnType,
        [Parameter(Mandatory=$true,ParameterSetName='ReturnStronglyTypedObject')]
        $ReturnTypeSingular,
        [ValidateSet("Get", "Delete")]
        [String]$Method="Get"
        
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

    
    if ($PSCmdlet.ParameterSetName -eq "ReturnObject")
    {
        Try
        {
            if ($ReturnFull -eq $true)
            {
                $Result = Invoke-WebRequest -Method $Method -Uri $Uri -Headers $headers
            }
            Else
            {
                $Result = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers
            }
            
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
    Elseif ($PSCmdlet.ParameterSetName -eq "ReturnStronglyTypedObject")
    {
        Add-InternalType -TypeName $ReturnType
        
        #Type Loaded. Use webrequest to query, since we'll do our own json parsing
        Try
        {
            $WebResult = Invoke-WebRequest -Method $Method -Uri $Uri -Headers $headers    
        }
        Catch
        {
            #TODO: Better error handling
            return
        }
        
        $jobj = [Newtonsoft.Json.Linq.JObject]::Parse($WebResult.Content)
        
        if ($ReturnTypeSingular)
        {
            $ThisObject = $jobj.ToObject($ReturnType)
            return $ThisObject
        }
        Else
        {
            $ReturnArray = @()
            foreach ($obj in $jobj["value"])
            {
                $thisobject = $obj.ToObject($ReturnType)
                $ReturnArray += $ThisObject
                $ThisObject = $null
            }
            
            return $ReturnArray
        }
        
        
        
    }
    
}