function Set-SplitLocation {
    # Change the directory to the one of the file
    param($Path)
    Set-Location (Split-Path $Path)
}
