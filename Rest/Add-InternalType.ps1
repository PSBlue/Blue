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
        $TypeText = get-type -Type $TypeName
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
        Elseif (test-path (join-path $Script:thismodulepath "classes\$TypeName.cs"))
        {
            $FilePath = join-path $Script:thismodulepath "classes\$TypeName.cs"
        }
        Elseif (test-path (join-path $Script:thismodulepath "classes\Base\$TypeName.cs"))
        {
            $FilePath = join-path $Script:thismodulepath "classes\Base\$TypeName.cs"
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
            Add-type -Path $FileRefs
        }


    }
}
