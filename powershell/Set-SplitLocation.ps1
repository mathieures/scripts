function Set-SplitLocation {
    param($Path)
    Set-Location (Split-Path $Path)
}
