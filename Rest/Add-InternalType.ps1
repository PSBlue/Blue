Function Add-InternalType
{
    Param (
        [String]$TypeName,
        [switch]$IsRecursed
    )

    #Check if we're good
    $TypeLoaded = $true
    try
    {
        $TypeText = Get-InternalType -Type $TypeName
    }
    catch
    {
        $TypeLoaded = $false
    }
        
    if ($TypeLoaded -eq $false)
    {
        #Find the file
        if (test-path $TypeName)
        {
            $FilePath = $TypeName
        }
        Else
        {
            $FilePath = (Get-ChildItem -path "$script:thismodulepath\Classes" -Recurse -File -Filter "$TypeName.cs").FullName
        }
        
        if ($FilePath)
        {
            #We have ze file
        }
        Else
        {
            #Could not find file
            throw "Unable to load $typename. Could not find file anywhere"
        }
        

        $FileRefs = @()
        $FileRefs += $FilePath

        $FileContent = get-content $FilePath
        #Get the refs
        $EndOfRefs = $false
        $LineNumber = 0
        Do {
            $FileLineContent = $FileContent[$LineNumber]
            if ($FileLineContent -like "//BLUEREF*")
            {
                $FileRef = $FileLineContent.Replace('//BLUEREF:',"")
                $FileObj = Get-ChildItem "$Script:thismodulepath\Classes" -Recurse | where {$_.BaseName -eq $FileRef}
                $FileRefs += Add-InternalType -TypeName ($Fileobj.FullName) -IsRecursed

            }
            else
            {
                $EndOfRefs = $true
            }
            $LineNumber ++
        }
        Until ($EndOfRefs -eq $true)

        if ($isrecursed)
        {
            return $FileRefs
        }
        Else
        {
            #Load Things
            Try 
            {
                Add-type -Path $FileRefs
            }
            Catch
            {

                if ($_.FullyQualifiedErrorId -match "TYPE_ALREADY_EXISTS")
                {}
                else
                {
                    throw $_.FullyQualifiedErrorId
                }
            }
            
        }


    }
}
