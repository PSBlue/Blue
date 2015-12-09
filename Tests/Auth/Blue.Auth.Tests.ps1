$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModuleFolderHere = (Get-Item $Here).FullName.Replace("\Tests","")
$here = $ModuleFolderHere
$ModuleFolder = Split-Path $moduleFolderHere -Parent
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
Import-Module "$ModuleFolder\blue.psd1" -force
Import-Module "$ModuleFolder\blue.psm1" -force

$FailingCred = New-Object System.Management.Automation.PsCredential("nope", ("nope" | convertTo-SecureString -asplainText -Force))
$SuceedingCred = New-Object System.Management.Automation.PsCredential($env:logonaccountusername, ($env:logonaccountuserpassword | convertTo-SecureString -asplainText -Force))

Function ParseGuid
{
    Param ($Guid)
    Try
    {
        $Guid = [System.Guid]::Parse($Guid)
    }
    Catch
    {
        return $null
    }
    
    return $Guid.Tostring()
}


#Tests tagged with "interactive"" cannot be run by CI
Describe -Tag "Interactive" "Connect-ArmSubscription" {
    It "Output subscription on success" {
        (Connect-ArmSubscription).SubscriptionId | Should not be $null
    }
    
    It "Have a guid-parseable output on success" {
        {[System.Guid]::Parse((Connect-ArmSubscription).SubscriptionId)} | Should not throw
    }
}

Describe "Connect-ArmSubscription" {
    It "Not throw on failure" {
        {Connect-ArmSubscription -credential $FailingCred -ErrorAction SilentlyContinue -ErrorVariable myErr} | Should not throw
    }

    It "Produce the right error message on failure" {
            Connect-ArmSubscription -credential $FailingCred -ErrorAction SilentlyContinue -ErrorVariable myErr
            $myerr[1].Exception.Message | Should be "Error Authenticating"
    }
    
    It "is able to log on to Azure" {
        (Connect-ArmSubscription -credential $SuceedingCred).SubscriptionId | Should Not BeNullOrEmpty
    }
    

    It "Have a guid-parseable output on success when subscriptionId is specified" {
        $Guid = (Connect-ArmSubscription -credential $SuceedingCred -SubscriptionId $env:subscriptionid).SubscriptionId
        $Result = ParseGuid -Guid $guid
        $Result | Should be $env:subscriptionid
    }

    It "Have a guid-parseable output on success when subscriptionId is not specified" {
        $Guid = (Connect-ArmSubscription -credential $SuceedingCred).SubscriptionId
        $Result = ParseGuid -Guid $guid
        $Result | Should be $env:subscriptionid
    }

}
 
Describe "ConfigFile" {
    [String]$Json = Get-Content "Config\apiversions.json" -Raw | convertfrom-Json
    
    It "should be parseable json" {
         $Json |  Should Not BeNullOrEmpty
    }
}
