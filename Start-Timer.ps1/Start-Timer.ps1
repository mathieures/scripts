function Start-Timer {
    # A timer (5s by default) cancellable by pressing any key. A sound is played at the end.
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [Alias('S','Sec','Time')]
            [int]$Seconds = 5,
            [string]$Activity = 'Timer', # The title of the timer (doesn't change the behaviour)
            [string]$Status = 'Waiting...', # The sub-title of the timer (doesn't change the behaviour)
        [Alias('Show','Visual','V','ProgressBar','Progress','Bar')]
            [switch]$ShowProgressBar, # Shows a progress bar at the top of the console
        [Alias('N')]
            [switch]$NotCancellable, # The timer is cancellable by pressing any key, by default
            [switch]$NoBeep # No sound played when finished
    )

    # Job handling the timer (and progressbar if specified)
    $TimerJob = Start-Job -Name 'TimerJob' {
        param([int]$Seconds, [string]$Activity, [string]$Status, $ShowProgressBar)
        # Note: switches are not supported by Jobs
        
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

    if(!($NotCancellable))
    {
        Write-Host 'Press any key to cancel'
        # Removes the 'Enter' keypress from entering the script
        Start-Sleep -milliseconds 110
        $Host.UI.RawUI.FlushInputBuffer()
    }

    while($TimerJob.State -eq 'Running')
    {
        # Update the written timer (and progressbar if specified)
        Receive-Job $TimerJob
        
        # If cancellable, wait for input for 100ms (= refresh the time+progressbar every 100ms)
        if(!($NotCancellable))
        {
            $MillisecondsRemaining = 100
            # Check every 10ms for input
            while( !($key = [Console]::KeyAvailable) -and ($MillisecondsRemaining -gt 0) )
            {
                Start-Sleep -Milliseconds 10
                $MillisecondsRemaining-=10
            }
            if($key)
            {
                $Host.UI.RawUI.FlushInputBuffer() # On enlève l'appui sur la touche, quelle qu'elle soit
                $PSCmdlet.WriteError(
                    (New-Object System.Management.Automation.ErrorRecord 'Ok, annulation.',
                        $null, 'NotSpecified', $null))
                Stop-Job $TimerJob
                Remove-Job $TimerJob
                return 1 # Cancelled
            }
        }
    }
    Remove-Job $TimerJob # Just remove the job as it is already stopped
    if(!$NoBeep) { [Media.Systemsounds]::Beep.play() }
    return 0 # Completed
}
