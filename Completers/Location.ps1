$ArgumentCompleter = @{
        Command = @(
            "Get-ArmResourceGroup",
            "Get-ArmVmImage"
        )
        Parameter = "Location"
        Description = ""
        ScriptBlock = {
        <#
        .SYNOPSIS
        .NOTES
        #>
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

        
        Get-ArmLocation |where {$_.Name -match $wordToComplete} |  ForEach-Object {
            $CompletionResult = @{
                CompletionText = $_.Name
                #ToolTip = 'Cloud Service in "{0}" region.' -f $PSItem.ExtendedProperties.ResourceLocation
                #ListItemText = '{0} ({1})' -f $PSItem.ServiceName, $PSItem.ExtendedProperties.ResourceLocation
                CompletionResultType = [System.Management.Automation.CompletionResultType]::ParameterValue
                }
            New-CompletionResult @CompletionResult
        }
    }
}

TabExpansionPlusPlus\Register-ArgumentCompleter @ArgumentCompleter