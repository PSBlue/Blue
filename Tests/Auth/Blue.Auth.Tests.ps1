$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModuleFolderHere = (Get-Item $Here).FullName.Replace("\Tests","")
$here = $ModuleFolderHere
$ModuleFolder = Split-Path $moduleFolderHere -Parent
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
Import-Module "$ModuleFolder\blue.psd1" -force

$FailingCred = New-Object System.Management.Automation.PsCredential("nope", ("nope" | convertTo-SecureString -asplainText -Force))

Describe "Connect-ArmSubscription" {
#    It "Accepts a credential parameter" {
#        Connect-ArmSubscription -Credential $FailingCred | Should Not Throw
#   }
    
#    It "Doesn't output anything on fail" {
#        Connect-ArmSubscription -Credential $FailingCred | Should be $null
#    }

    It "Doesn't output anything on success" {
        Connect-ArmSubscription | Should be $null
    }

}
