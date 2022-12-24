function Get-SHA1($string) {
    # Return an object containing the SHA1 hash of the $string parameter.
    # To access the raw string, use the .Hash attribute of the returned object.
    Get-FileHash -Algorithm SHA1 -InputStream (
        [System.IO.MemoryStream]::new(
            [System.Text.Encoding]::UTF8.GetBytes($string)
        )
    )
}