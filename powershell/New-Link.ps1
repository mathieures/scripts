function New-Link {
    param(
        [ValidateSet('SymbolicLink','HardLink')]
        $Type = 'SymbolicLink',
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$Name
    )
    New-Item -Path $Name -ItemType $Type -Value $Target
}
