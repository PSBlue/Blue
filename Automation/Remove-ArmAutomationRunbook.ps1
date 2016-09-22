function Remove-ArmAutomationRunbook {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Blue.AutomationRunbook] $Runbook,

        [Switch] $Force
    )
    begin {
        #This is the basic test we do to ensure we have a valid connection to Azure
        if (!(Test-InternalArmConnection)) {
            Write-Error -Message "Please use Connect-ArmSubscription" -ErrorAction Continue
            return
        }
    } process {
        $Uri = 'https://management.azure.com{0}' -f $Runbook.Id
        if ($Force -or $PSCmdlet.ShouldProcess($Runbook.Name)) {
            Get-InternalRest -Uri $Uri -ProviderName 'Microsoft.Automation' -Method Delete
        }
    }
}