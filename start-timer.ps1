# A timer (of 5s by default)
function Start-Timer {
    param([int]$Seconds = 5, $Activity = "Timer", $Status = "Waiting...", [switch]$ShowProgressBar)

    $i = $Seconds
    while($i -ne 0)
    {
        if($ShowProgressBar) {
            Write-Progress -Activity $Activity -Status $Status -SecondsRemaining $i -PercentComplete ((($Seconds-$i)/$Seconds)*100)
        }
        else {
            Write-Progress -Activity $Activity -Status $Status -SecondsRemaining $i
        }
        Start-Sleep 1
        $i--
    }
}

# Start-Timer -Seconds 15 -Activity "A 15s timer" -ShowProgressBar