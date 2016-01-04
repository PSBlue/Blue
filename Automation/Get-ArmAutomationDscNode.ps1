function Get-ArmAutomationDscNode {
    [CmdletBinding(DefaultParameterSetName='List')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='Named')]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory, ValueFromPipeline)]
        [Blue.AutomationAccount] $AutomationAccount,

        [Switch] $Raw
    )
    begin {
        #This is the basic test we do to ensure we have a valid connection to Azure
        if (!(Test-InternalArmConnection)) {
            Write-Error -Message "Please use Connect-ArmSubscription" -ErrorAction Continue
            return
        }
    } process {
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
                    
                } else {
                    Write-Output -InputObject $a
                }
            }
        }
    }
}