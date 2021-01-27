function Start-TTS {
    param(
        [Parameter(ValueFromPipeline)]
            [string[]]$Text,
        [ValidateRange(0,2)]
            [int]$Voice = 0,
        [Alias('Alt','EN','US','Anglais')]
            [switch]$AlternativeVoice,
        [Alias('Speed')]
            [int]$Rate = 0
    )
    
    BEGIN {
        $sp = New-Object -ComObject SAPI.SpVoice
        $sp.Rate = $Rate
        if($AlternativeVoice) { $sp.Voice = $sp.GetVoices().Item(1) }
        else { $sp.Voice = $sp.GetVoices().Item($Voice) }
    }
    PROCESS {
        if([string]::IsNullOrEmpty($Text))
        {
            do {
                $Text = Read-Host 'Words to say'
                $null = $sp.Speak($Text)
            } until([string]::IsNullOrEmpty($Text))
        }
        else { $null = $sp.Speak($Text) }
    }
}
