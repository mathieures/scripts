function New-Link {
    # Create a link (symbolic by default) easier
    param(
        [ValidateSet('SymbolicLink','HardLink')]
            $Type = 'SymbolicLink',
        [Parameter(Mandatory)]
            [string]$Target, # The target, where the link should link to
        [Parameter(Mandatory)]
            [string]$Name # The name of the newly created link
    )
    New-Item -Path $Name -ItemType $Type -Value $Target
}
