function Get-ArmAutomationDscNode {
    [CmdletBinding(DefaultParameterSetName='List')]
    param (
        [Parameter(Mandatory, ParameterSetName='Named')]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory, ParameterSetName='Id')]
        [ValidateNotNullOrEmpty()]
        [string] $Id,

        [Parameter(ValueFromPipeline)]
        [Blue.AutomationAccount] $AutomationAccount,

        [Parameter(ParameterSetName='List')]
        [Switch] $Raw
    )
    begin {
        #This is the basic test we do to ensure we have a valid connection to Azure
        if (!(Test-InternalArmConnection)) {
            Write-Error -Message "Please use Connect-ArmSubscription" -ErrorAction Continue
            return
        }
    } process {
		if ($null -eq $AutomationAccount -and $null -eq $script:AutomationAccount) {
			Write-Error -Message 'Please pass an automation account object to the AutomationAccount parameter or use Select-ArmAutomationAccount before calling this function.' -ErrorAction Stop
		}
		if ($AutomationAccount) {
			#explicitly defined as param
			$AA = $AutomationAccount
		} else {
			#get from currently selected automation account
			$AA = $script:AutomationAccount
		}
        $Params = @{
            Uri = 'https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Automation/automationAccounts/{2}/nodes' -f $script:CurrentSubscriptionId, $AutomationAccount.ResourceGroupName, $AutomationAccount.Name
            ProviderName = 'Microsoft.Automation'
        }

        if (-not $Raw) {
            $Params.Add('ReturnType','Blue.AutomationDscNode')
            $Params.Add('ReturnTypeSingular',$false)
        }
        
        $DscNodes = Get-InternalRest @Params

        if ($Raw) {
            $DscNodes
        } else {
            foreach ($a in $DscNodes) {
                if ($MyInvocation.BoundParameters.Keys -contains 'Name' -and $a.Name -ne $Name) {
                    
                } elseif ($MyInvocation.BoundParameters.Keys -contains 'Id' -and $a.id -ne $Id) {
                    
                } else {
                    $a.ResourceGroupName = $AutomationAccount.ResourceGroupName
                    $a.AutomationAccountName = $AutomationAccount.Name
                    Write-Output -InputObject $a
                }
            }
        }
    }
}