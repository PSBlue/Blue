Param ([switch]$Force)

$LocalVarsContent = Get-Content "LocalVars.Config" -Raw
$LocalVars = $LocalVarsContent | ConvertFrom-Json

Foreach ($var in $LocalVars)
{
    $VarName = $Var.Name
    
    if (!(Get-Childitem "env:" | where {$_.Name -eq $VarName}))
    {
        $SetVar = $true
    }
    
    if ($Force)
    {
        $SetVar = $true
    }
    
    
    if ($Setvar -eq $true)
    {
        Write-verbose "Adding env var $varname with value $($Var.Value)"
        [Environment]::SetEnvironmentVariable($VarName, ($Var.Value), "Process")
    }
    
    
}