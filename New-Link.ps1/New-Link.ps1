function New-Link {
    # Create a link (symbolic by default) the easy way
    param(
        [ValidateSet('SymbolicLink','HardLink')]
            $Type = 'SymbolicLink',
        [Parameter(Mandatory, Position=0)]
            [string]$Name, # The name of the newly created link
        [Parameter(Mandatory, Position=1)]
            [string]$Target # The target, where the link should point
    )
    $TargetFile = Get-Item $Target
    # If it exists, it's either a directory or it shouldn't be the name
    if (Test-Path $Name)
    {
        if (Select-Object -InputObject (Get-Item $Name) -Property PsIsContainer)
        {
            $FilePath = $File.FullName + $TargetFile.Name
        }
    }
    else { $FilePath = $Name }

    # If the file already exists, it throws an error by itself
    New-Item -Path $FilePath -ItemType $Type -Value $TargetFile.FullName
}