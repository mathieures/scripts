function Set-LocationToFilePath($Path) {
    # Change the directory to the one of the file. An alias like 'cdf' could be useful.
    Set-Location (Split-Path $Path)
}