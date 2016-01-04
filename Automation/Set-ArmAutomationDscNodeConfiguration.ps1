function Set-ArmAutomationDscNodeConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Blue.AutomationDscNode] $Node,

        [Parameter(Mandatory)]
        [String] $ConfigurationName
    )
    begin {
        #This is the basic test we do to ensure we have a valid connection to Azure
        if (!(Test-InternalArmConnection)) {
            Write-Error -Message "Please use Connect-ArmSubscription" -ErrorAction Continue
            return
        }
    } process {
        $PutUri = 'https://management.azure.com{0}' -f $Node.Id
        $Data = @{
            nodeConfiguration = @{
                name = $ConfigurationName
            }
        }
        $Patch = Post-InternalRest -Uri $PutUri -ProviderName 'Microsoft.Automation' -Method Patch -Data $Data -ReturnType Blue.AutomationDscNode -ReturnTypeSingular $true
        $Patch.ResourceGroupName = $Node.ResourceGroupName
        $Patch.AutomationAccountName = $Node.Name
        Write-Output -InputObject $Patch
    }
}