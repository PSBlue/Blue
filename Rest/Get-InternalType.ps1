Function Get-InternalType
{
    <#
    .Synopsis
        Gets the types that are currenty loaded in .NET, 
        or gets information about a specific type
    .Description
        Gets all of the loaded types, or gets the possible values for an 
        enumerated type or value.
    .Example
        # Gets all loaded types
        Get-Type
    .Example
        # Gets types from System.Management.Automation
        Get-Type -Assembly ([PSObject].Assembly)
    .Example
        # Gets all of the possible values for the ApartmentState property
        [Threading.Thread]::CurrentThread.ApartmentState | Get-Type
    .Example
        # Gets all of the possible values for an apartmentstate
        [Threading.ApartmentState] | Get-Type
    #>
    [CmdletBinding(DefaultParameterSetName="Assembly")]   
    param(
    # The assembly to collect types from
    [Parameter(ParameterSetName="Assembly", ValueFromPipeline=$true)]
    [Reflection.Assembly[]]
    $Assembly,
    
    # The enumerated value to get all of the possibilties of
    [Parameter(ParameterSetName="Enum", ValueFromPipeline=$true)]
    [Enum]
    $Enum,

    # Returns possible values if the Type was an enumerated value
    # Otherwise, returns the static members of the type
    [Parameter(ParameterSetName="Type", ValueFromPipeline=$true)]
    [Type[]]
    $Type
    )

    Process
    {
        switch ($psCmdlet.ParameterSetName) {
            Assembly {
                if (! $psBoundParameters.Count -and ! $args.Count) {
                    $Assembly = [AppDomain]::CurrentDomain.GetAssemblies()
                }
                foreach ($asm in $assembly) {
                    if ($asm) { $asm.GetTypes() }  
                }
            }          
            Type {
                foreach ($t in $type) {
                    if ($t.IsEnum) {
                        [Enum]::GetValues($t)
                    } else {
                        $t  | Get-Member -static
                    }                
                }
            }
            Enum {
                [Enum]::GetValues($enum.GetType())        
            }
       }
    }

}