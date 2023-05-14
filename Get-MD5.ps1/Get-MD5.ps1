function Get-MD5($string) {
    # Return an object containing the MD5 hash of the $string parameter.
    # To access the raw string, use the .Hash attribute of the returned object.
    Get-FileHash -Algorithm MD5 -InputStream (
        [System.IO.MemoryStream]::new(
            [System.Text.Encoding]::UTF8.GetBytes($string)
        )
    )
}