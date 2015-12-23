$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModuleFolderHere = (Get-Item $Here).FullName.Replace("\Tests","")
$here = $ModuleFolderHere
$ModuleFolder = Split-Path $moduleFolderHere -Parent
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
Import-Module "$ModuleFolder\blue.psd1" -force -Verbose:$false
Import-Module "$ModuleFolder\blue.psm1" -force -Verbose:$false

if (Get-item "LocalVars.Config")
{
    Tests\ConfigureTestEnvironment.ps1
}

$FailingCred = New-Object System.Management.Automation.PsCredential("nope", ("nope" | convertTo-SecureString -asplainText -Force))
$SuceedingCred = New-Object System.Management.Automation.PsCredential($env:logonaccountusername, ($env:logonaccountuserpassword | convertTo-SecureString -asplainText -Force))

#Connect to azure
$null = Connect-ArmSubscription -credential $SuceedingCred -SubscriptionId $env:subscriptionid
$RGs = Get-ArmResourceGroup

Describe "Get-ResourceGroup" {
    It "Is able to get a single RG" {
        $null = Connect-ArmSubscription -credential $SuceedingCred -SubscriptionId $env:subscriptionid
        $RG[0].Name
        (Get-ArmResourceGroup -Name $RGs[0]).Gettype().FullName | Should be "Blue.ResourceGroup"
    }
    
    It "Is able to get multiple RGs" {
        $null = Connect-ArmSubscription -credential $SuceedingCred -SubscriptionId $env:subscriptionid
        (Get-ArmResourceGroup -Name $RGs[0]).GetType().Basetype.FullName | Should be "System.Array"
    }
    
    It "Does not throw on errors" {
        $null = Connect-ArmSubscription -credential $SuceedingCred -SubscriptionId $env:subscriptionid
        Get-ArmResourceGroup -Name "Kwerpackle" | Should not throw
    }
}

