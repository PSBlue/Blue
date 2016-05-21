write-output "PS version is: $($PSVersionTable.PSVersion.tostring())"
Write-Output "OS version is: $(Get-WmiObject win32_operatingsystem | select -ExpandProperty version)"
write-output "Here is: $(get-location | select -ExpandProperty path)"

$here = get-location | select -ExpandProperty path
$ModuleFolderHere = get-location | select -ExpandProperty path
$here = $ModuleFolderHere
$ModuleFolder = Split-Path $moduleFolderHere -Parent

$VerbosePreference = Continue
if (Get-item "$ModuleFolder\LocalVars.Config" -ErrorAction SilentlyContinue)
{
    . $ModuleFolder\Tests\ConfigureTestEnvironment.ps1 -FilePath $ModuleFolder\LocalVars.config
}
$VerbosePreference = SilentlyContinue

write-outout "Env things:"
write-output "env:logonaccountusername: $($env:logonaccountusername)"
