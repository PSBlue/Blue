function Get-ArmAutomationAccount {
    [CmdletBinding(DefaultParameterSetName='None')]
    param (
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(ValueFromPipeline, ParameterSetName='ResourceGroup')]
        [Blue.ResourceGroup] $ResourceGroup,

		[Parameter(ParameterSetName='Current')]
		[switch] $Current
    )
    begin {
        #This is the basic test we do to ensure we have a valid connection to Azure
        if (!(Test-InternalArmConnection)) {
            Write-Error -Message "Please use Connect-ArmSubscription" -ErrorAction Continue
            return
        }
    } process {
		if (-not $Current) {
			if ($PSCmdlet.ParameterSetName -eq 'ResourceGroup') {
				$uri = 'https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Automation/automationAccounts' -f $script:CurrentSubscriptionId, $ResourceGroup.Name
			} else {
				$uri = 'https://management.azure.com/subscriptions/{0}/providers/Microsoft.Automation/automationAccounts' -f $script:CurrentSubscriptionId
			}
			$AutomationAccounts = Get-InternalRest -Uri $Uri -ReturnType "Blue.AutomationAccount" -ReturnTypeSingular $false -ProviderName 'Microsoft.Automation'
			foreach ($a in $AutomationAccounts) {
				if ($MyInvocation.BoundParameters.Keys -contains 'Name' -and $a.Name -ne $Name) {
                
				} else {
					$a.ResourceGroupName = $a.id.Split('/')[4]
					$RegUri = 'https://management.azure.com/{0}/agentRegistrationInformation' -f $a.Id
					$RegInfo = Get-InternalRest -Uri $RegUri -ProviderName 'Microsoft.Automation'
					$a.endpoint = $RegInfo.endpoint
					$a.PrimaryKey = $RegInfo.keys.primary
					$a.SecondaryKey = $RegInfo.keys.secondary
					$a.dscMetaConfiguration = $RegInfo.dscMetaConfiguration
					Write-Output -InputObject $a
				}
			}
		} else {
			Write-Output -InputObject $script:AutomationAccount
		}
    }
}