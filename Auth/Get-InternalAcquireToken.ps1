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
        [String]$PromptBehavior
    )
    

    

	$AuthContext = New-Object -TypeName Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext -ArgumentList ($LoginUrl)	

    if ($PSCmdlet.ParameterSetName -eq "ConnectByCredObject")
    {
        $PromptBehavior = [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Never
        
        Try
        {
            $UserCredential = New-Object -TypeName Microsoft.IdentityModel.Clients.ActiveDirectory.UserCredential -ArgumentList ($Credential.UserName, $Credential.Password)
            $authResult = $authContext.AcquireToken($ResourceUrl,$ClientId, $UserCredential)
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
            $ThisPromptBehavior = [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Auto
        }
        Try
        {
            $authResult = $authContext.AcquireToken($ResourceUrl,$ClientId, $RedirectUri, $ThisPromptBehavior)
        }
        Catch
        {
            if ($PromptBehavior -eq "Suppress")
            {
                #If that failed, and suppress is on, switch to auto
                $ThisPromptBehavior = [Microsoft.IdentityModel.Clients.ActiveDirectory.PromptBehavior]::Always
                $authResult = $authContext.AcquireToken($ResourceUrl,$ClientId, $RedirectUri, $ThisPromptBehavior)
            }
        }
        
    }

    if ($authResult)
    {
        Return $authResult
    }


	
}

