function Start-TTS {
    $sp = New-Object -ComObject SAPI.SpVoice

    if ($args[0] -eq $null) {
        $words = Read-Host "Words to say"

        While($words -ne ""){
            $null = $sp.Speak($words)
            $words = Read-Host "Words to say"
        }
    }
    else { $null = $sp.Speak($args) }
}