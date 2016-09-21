Function Post-InternalRest
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
		[Parameter(Mandatory=$false)]
		[PsObject]$Data,
		[Parameter(Mandatory=$true,ParameterSetName='ReturnStronglyTypedObject')]
        $ReturnType,
        [Parameter(Mandatory=$true,ParameterSetName='ReturnStronglyTypedObject')]
        $ReturnTypeSingular,
        [ValidateSet("Post", "Put", "Patch")]
        [String]$Method="Post",
        [bool]$ReturnFull=$False
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
		#TODO Make sure we're within the timing period of the Access Token
		$TokenExpiry = $script:TokenExpirationUtc
		
	}

    $headers = @{
            "Authorization"="Bearer $BearerToken"
            "Content-Type"="application/json"
        }
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
	
	if ($Data)
	{
		$JsonData = $data | ConvertTo-Json -Depth 20
	}
	
	$Params = @{
		"Method"=$Method;
		"Uri"=$Uri;
		"Headers"=$Headers
		}
	
	if ($JsonData)
	{
		$Params.add("Body",$JsonData)
	}
	
	if ($PSCmdlet.ParameterSetName -eq "ReturnObject")
    {
        Try
        {
            
            if ($ReturnFull -eq $true)
            {
                $Result = Invoke-WebRequest @Params -UseBasicParsing
            }
            Else
            {
                $Result = Invoke-RestMethod @Params -UseBasicParsing
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
            $WebResult = Invoke-WebRequest @Params -UseBasicParsing
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
