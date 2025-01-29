# Equivalent (with less features) of the ssh-copy-id from Linux-based systems
# Thanks to Augie Gardner https://serverfault.com/a/583659/1003865
param(
    [Parameter(Mandatory)]
    [String] $Destination,
    [string] $KeyFilePath = "$env:USERPROFILE\.ssh\id_rsa.pub",
    [int] $Port = 22,
    [Alias('Y')]
    [switch] $AssumeYes
)

if (!$KeyFilePath.EndsWith('.pub') -and !$AssumeYes) {
    $Answer = Read-Host -Prompt "'$KeyFilePath' does not end with '.pub'. Continue nonetheless? (y/N)"
    if ($Answer -ine 'y') {
        Write-Output 'Ok, cancelled.'
        return
    }
}

Get-Content -Path $KeyFilePath | ssh -p $Port $Destination "mkdir -p ~/.ssh ; cat >> ~/.ssh/authorized_keys"