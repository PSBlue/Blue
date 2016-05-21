$ThisFolder = get-location | select -ExpandProperty path
$TestsFolder = join-path $ThisFolder "Tests"
Import-Module "blue.psd1"
#Import-Module "$ModuleFolder\blue.psm1" -force

if (Get-item "$ThisFolder\LocalVars.Config" -ErrorAction SilentlyContinue)
{
    . "$TestsFolder\ConfigureTestEnvironment.ps1" -FilePath "$ThisFolder\LocalVars.config"
}

$FailingCred = New-Object System.Management.Automation.PsCredential("nope", ("nope" | convertTo-SecureString -asplainText -Force))
$SuceedingCred = New-Object System.Management.Automation.PsCredential($env:logonaccountusername, ($env:logonaccountuserpassword | convertTo-SecureString -asplainText -Force))
$WorkingSubscriptionId = $env:SubscriptionId

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

