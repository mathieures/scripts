# A timer (of 5s by default) cancellable by pressing any key
function Start-Cancellable-Timer {
    param([int]$Seconds = 5, $Activity = "Timer", $Status = "Waiting...", [switch]$ShowProgressBar)

    # Job handling the progressbar
    $TimerJob = Start-Job -Name "TimerJob" {
        param([int]$Seconds = 5, $Activity = "Timer", $Status = "Waiting...", $ShowProgressBar)
        # This time, ShowProgressBar is not a switch: switches don't work with jobs
        
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
    } -ArgumentList $Seconds, $Activity, $Status, $ShowProgressBar

    Write-Host "Press any key to cancel."

    # Removes the 'Enter' key press starting the script (known issue of Powershell)
    Start-Sleep -milliseconds 110
    $Host.UI.RawUI.FlushInputBuffer()

    while($TimerJob.State -eq "Running")
    {
        # Updating the progressbar
        Receive-Job $TimerJob

        # Waiting for input for 100ms (= refreshing the progressbar every 100ms), checking every 10ms for input
        $MillisecondsRemaining = 100
        while((-not ($key = $Host.UI.RawUI.KeyAvailable)) -and ($MillisecondsRemaining -ne 0))
        {
            Start-Sleep -Milliseconds 10
            $MillisecondsRemaining-=10
        }
        if($key) {
            $Host.UI.RawUI.FlushInputBuffer() # Removing the pressed key from the console, whatever it is
            Write-Host "Ok, cancelling." -ForegroundColor Yellow
            Stop-Job $TimerJob
            Remove-Job $TimerJob
            return 1 # Cancelled
        }
    }
    Remove-Job $TimerJob
    return 0 # Completed
}

# Start-Cancellable-Timer -Seconds 15 -Activity "A 15s timer" -ShowProgressBar # Example of it working