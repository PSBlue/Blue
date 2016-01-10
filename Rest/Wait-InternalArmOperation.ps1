Function Wait-InternalArmOperation
{
    Param (
        [String[]]$Uri,
        $InProgressStatus=202,
        $FinishedStatus=200,
        $ApiVersion
    )
    
    $Counter = 1
    $OperationIsFinished = $false
    $OperationStart = Get-Date
    #Loop while waiting until the statuscode turns from 202 (in progress) to 200 (done)
    Do {
        $nowtime = Get-Date
        $ElapsedTime = $nowtime - $OperationStart
        Write-Verbose "Waiting for arm operation (elapsed seconds: $($ElapsedTime.Totalseconds))"
        $AllCompleted = $true
        $UriCounter = 0
        Foreach ($ThisUri in $Uri)
        {
            $UriCounter ++
            Write-verbose "Waiting for operation $UriCounter of $($uri.count)"
            $OperationResult = Get-InternalRest -Uri $ThisUri -ReturnFull $true -ApiVersion $ApiVersion
            if ($OperationResult.StatusCode -eq $FinishedStatus)
            {
                #Arm Operation done, remove self from array
                $Uri = $uri | where {$_ -ne $thisuri}
                Write-verbose "Operation $UriCounter done. Waiting for $($Uri.Count) more operations"
                
            }
            ElseIf ($OperationResult.StatusCode -eq $InProgressStatus)
            {
                #Arm operation Still in progress
                $AllCompleted = $false
            }
            Else
            {
                #No idea whats going on
            }
             
        }
        if ($AllCompleted -eq $true)
        {
            $OperationIsFinished = $true
        }
        
        #Start sleeping after a while with a bit of easing back
        if ($counter -gt 5 -and $counter -lt  10)
        {
            Start-Sleep -Milliseconds 500
        }
        ElseIf ($counter -gt 11 -and $counter -lt  50)
        {
            Start-Sleep -Seconds 2
        }
        ElseIf ($counter -gt 50 -and $counter -lt  999)
        {
            Start-Sleep -Seconds 5
        }
        $counter ++   
        
    }
    Until (($OperationIsFinished -eq $true) -or ($Counter -gt 999))
}