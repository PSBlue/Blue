$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModuleFolderHere = (Get-Item $Here).FullName.Replace("\Tests","")
$here = $ModuleFolderHere
$ModuleFolder = Split-Path $moduleFolderHere -Parent
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
Import-Module "$ModuleFolder\blue.psd1" -force -Verbose:$false
Import-Module "$ModuleFolder\blue.psm1" -force -Verbose:$false

if (Get-item "LocalVars.Config" -ErrorAction SilentlyContinue)
{
    Tests\ConfigureTestEnvironment.ps1
}

$FailingCred = New-Object System.Management.Automation.PsCredential("nope", ("nope" | convertTo-SecureString -asplainText -Force))
$SuceedingCred = New-Object System.Management.Automation.PsCredential($env:logonaccountusername, ($env:logonaccountuserpassword | convertTo-SecureString -asplainText -Force))

#Connect to azure
$null = Connect-ArmSubscription -credential $SuceedingCred -SubscriptionId $env:subscriptionid


Describe "Get-ResourceGroup" {
    It "Is able to get a single RG" {
        #$null = Connect-ArmSubscription -credential $SuceedingCred -SubscriptionId $env:subscriptionid
        $RGs = Get-ArmResourceGroup
        $Rg = Get-ArmResourceGroup -Name ($rgs[0].Name)
        $RGs[0].Gettype().FullName | Should be "Blue.ResourceGroup"
    }
    
    It "Is able to get multiple RGs" {
        $RGs = Get-ArmResourceGroup
        $RGs.GetType().BaseType.ToString() | Should be "System.Array"
    }
    
    It "Does not throw on errors" {
        Get-ArmResourceGroup -Name "Kwerpackle" -ErrorAction SilentlyContinue -ErrorVariable myerr
        $MyErr | Should Not BeNullOrEmpty
    }
}

