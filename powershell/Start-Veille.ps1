function Start-Veille {
    param(
        [Alias('T')]
            [int]$Seconds = 5
    )
    if(Start-Timer -Seconds $Seconds -Activity 'Mise en veille' -ShowProgressBar -C) { return }

    Add-Type -AssemblyName System.Windows.Forms
    $PowerState = [System.Windows.Forms.PowerState]::Suspend;
    $Force = $false;
    $DisableWake = $false;
    [System.Windows.Forms.Application]::SetSuspendState($PowerState, $Force, $DisableWake);
}
