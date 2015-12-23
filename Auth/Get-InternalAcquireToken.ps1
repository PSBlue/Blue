Function Get-InternalAcquireToken
{
    [CmdletBinding(DefaultParameterSetName='VisibleCredPrompt')]
    Param (
        [Parameter(Mandatory=$true,ParameterSetName='ConnectByCredObject')]
		[System.Management.Automation.PSCredential]$Credential,

        [Parameter(Mandatory=$False,ParameterSetName='ConnectByCredObject')]
        [Parameter(Mandatory=$true,ParameterSetName='VisibleCredPrompt')]
        [String]$RedirectUri,
        
        [Parameter(Mandatory=$True)]
        [String]$LoginUrl,

        [Parameter(Mandatory=$True)]
        [String]$ClientId,

        [Parameter(Mandatory=$True)]
        [String]$ResourceUrl,

        [ValidateSet("Never", "Auto", "Suppress", "Always")]
        [String]$PromptBehavior,
        
        [Parameter(Mandatory=$True,ParameterSetName='ConnectByRefreshToken')]
        $RefreshToken
    )
    

    $AuthContext = New-Object -TypeName Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext -ArgumentList ($LoginUrl)

    if ($PSCmdlet.ParameterSetName -eq "ConnectByCredObject")
    {
        $PromptBehavior = [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Never
        
        Try
        {
            $UserCredential = New-Object -TypeName Microsoft.IdentityModel.Clients.ActiveDirectory.UserCredential -ArgumentList ($Credential.UserName, $Credential.Password)
            $authResult = $AuthContext.AcquireToken($ResourceUrl,$ClientId, $UserCredential)
        }
        Catch
        {
        }
        
    }
    ElseIf($PSCmdlet.ParameterSetName -eq "VisibleCredPrompt")
    {
        if ($PromptBehavior -eq "Always")
        {
            $ThisPromptBehavior = [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Always
        }
        Elseif ($PromptBehavior -eq "Suppress")
        {
            $ThisPromptBehavior = [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Never
        }
        Else
        {
            #Check the credential cache to see if we already have an entry we can use
            $CacheHit = $AuthContext.TokenCache.ReadItems() | where {$_.Authority -eq $LoginUrl}
            if ($CacheHit)
            {
                Write-verbose "     Attempting to authenticate using TokenCache"
                $ThisPromptBehavior = [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Never        
            }
            Else
            {
                $ThisPromptBehavior = [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Auto
            }
            
        }
        Try
        {
            $authResult = $AuthContext.AcquireToken($ResourceUrl,$ClientId, $RedirectUri, $ThisPromptBehavior)
        }
        Catch
        {
            if ($_.Exception.Message -match "User canceled authentication")
            {
                Write-error "User Canceled authentication"
                return
            }
            if (($PromptBehavior -eq "Suppress") -or ($PromptBehavior -eq "Auto"))
            {
                #If that failed, and suppress is on, switch to auto
                $ThisPromptBehavior = [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Always
                $authResult = $AuthContext.AcquireToken($ResourceUrl,$ClientId, $RedirectUri, $ThisPromptBehavior)
            }
        }
        
    }
    ElseIf($PSCmdlet.ParameterSetName -eq "ConnectByRefreshToken")
    {
        try
        {
            $authResult = $AuthContext.AcquireTokenByRefreshToken($RefreshToken,$ClientId)    
        }
        Catch
        {
            Write-error "Error acquiring updated token using refresh token."
            return
        }
        
    }

    if ($authResult)
    {
        Return $authResult
    }

}

