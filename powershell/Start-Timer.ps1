function Start-Timer {
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [Alias('S','Sec','Time')]
            [int]$Seconds = 5,
            [string]$Activity = 'Timer',
            [string]$Status = 'Attente...',
        [Alias('Show','Visual','V')]
            [switch]$ShowProgressBar,
        [Alias('N')]
            [switch]$NotCancellable, # the timer is cancellable by pressing any key, by default
            [switch]$NoBeep # no beep when finished
    )

    # Job handling the progressbar
    $TimerJob = Start-Job -Name 'TimerJob' {
        param([int]$Seconds, [string]$Activity, [string]$Status, $ShowProgressBar)
        # switches are not supported by Jobs
        
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
        # update the progressbar
        Receive-Job $TimerJob
        
        if(!($NotCancellable))
        {
            # wait for input for 100ms (= refresh the progressbar every 100ms), checking every 10ms for input
            $MillisecondsRemaining = 100
            while( !($key = [Console]::KeyAvailable) -and ($MillisecondsRemaining -gt 0) )
            {
                Start-Sleep -Milliseconds 10
                $MillisecondsRemaining-=10
            }
            if($key)
            {
                $Host.UI.RawUI.FlushInputBuffer() # on enlève l'appui sur la touche, quelle qu'elle soit
                $PSCmdlet.WriteError(
                    (New-Object System.Management.Automation.ErrorRecord 'Ok, annulation.',
                        $null, 'NotSpecified', $null))
                Stop-Job $TimerJob
                Remove-Job $TimerJob
                return 1 # Cancelled
            }
        }
    }
    Remove-Job $TimerJob
    if(!$NoBeep) { [Media.Systemsounds]::Beep.play() }
    return 0 # Completed
}
