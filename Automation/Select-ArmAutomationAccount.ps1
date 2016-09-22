function Select-ArmAutomationAccount {
	[cmdletbinding()]
	param (
		[Parameter(Mandatory, ValueFromPipeline)]
        [Blue.AutomationAccount] $AutomationAccount
	)
	process {
		Set-Variable -Name AutomationAccount -Value $AutomationAccount -Scope 1
	}
}