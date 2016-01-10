Function Invoke-InternalStringToArray
{
    Param ($InputString)
    $TotalChars = $InputString.Length
    $CharArray = @()
    $ThisCounter = 0
    Do {
        $CharArray += $InputString[$ThisCounter]
        $ThisCounter ++
    }
    Until ($ThisCounter -eq $TotalChars)
    $TotalChars = $null
    $CharArray
}