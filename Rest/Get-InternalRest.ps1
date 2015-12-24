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
        $ProviderName,
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
	
    if (($ApiVersion -eq $null) -and ($ProviderName -ne $null))
    {
        #Lookup the api version
        $ApiVersion = $ApiVersions | where {$_.ProviderName -eq $ProviderName} | Select -expandProperty "api-version"
    }
    Elseif (($ApiVersion -eq $null) -and ($ProviderName -eq $null))
    {
        Write-error "Neither apiversion or providername was specified. "
        return
        
    }
    ElseIf ($ApiVersion)
    {
        #All good
    }
    Else
	{
        #Best-efford attempt to get the apiversion
        Foreach ($ApiVersionEntry in $ApiVersions)
        {
            if ($Uri -match $ApiVersionEntry.ProviderName)
            {
                $ApiVersion = $ApiVersionEntry."api-version"
            }
        }
    
        if ($apiversion)
        {
            Write-warning "Best-efford attempt to figure out the api-version resulted in version $ApiVersion. This may be incorrect"
        }        
        Else
        {
            Write-error "Could not calculate api-version. The calling function should specify providername or apiversion."
            return
        }        
        
	}
	
    
	
	if ($BearerToken -eq $null)
	{
		$BearerToken = $script:AuthToken
		if (-not (Test-InternalTokenNotExpired -Token $BearerToken)) {
            Write-Error -Message "Authentication token has expired. Run Connect-ArmSubscription to acquire a new one" -ErrorAction Stop
        }
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