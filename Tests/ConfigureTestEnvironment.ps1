Param ($FilePath, [switch]$Force)

$LocalVarsContent = Get-Content $FilePath -Raw
$LocalVars = $LocalVarsContent | ConvertFrom-Json
write-output "PS version is: $($PSVersionTable.PSVersion.tostring())"
Write-Output "OS version is: $(Get-WmiObject win32_operatingsystem | select -ExpandProperty version)"

Foreach ($var in $LocalVars)
{
    $VarName = $Var.Name
    Write-Verbose "Processing $varname"
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