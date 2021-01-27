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

    # Job qui s'occupe de la progressbar
    $TimerJob = Start-Job -Name 'TimerJob' {
        param([int]$Seconds, [string]$Activity, [string]$Status, $ShowProgressBar)
        # obligé de ne pas utiliser un switch ici, car les Jobs ne les supportent pas
        
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
        Write-Host 'Appuyer sur une touche pour annuler'
        # Enlève l'appui sur Entrée du lancer du script
        Start-Sleep -milliseconds 110
        $Host.UI.RawUI.FlushInputBuffer()
    }

    while($TimerJob.State -eq 'Running')
    {
        # on met à jour la progressbar
        Receive-Job $TimerJob
        
        if(!($NotCancellable))
        {
            # on attend un input pendant 100ms (= on refresh la progressbar toutes les 100ms), on teste toutes les 10ms pour un input
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
                return 1 # Annulé
            }
        }
    }
    Remove-Job $TimerJob
    if(!$NoBeep) { [Media.Systemsounds]::Beep.play() }
    return 0 # Complété
}
