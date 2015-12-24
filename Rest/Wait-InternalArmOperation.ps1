Function Wait-InternalArmOperation
{
    Param (
        $Uri,
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
        $OperationResult = Get-InternalRest -Uri $Uri -ReturnFull $true -ApiVersion $ApiVersion
        if ($OperationResult.StatusCode -eq $FinishedStatus)
        {
            #Arm Operation done
            $OperationIsFinished = $true
        }
        ElseIf ($OperationResult.StatusCode -eq $InProgressStatus)
        {
            #Arm operation Still in progress
        }
        Else
        {
            #No idea whats going on
        }
        
        #Start sleeping after a while
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