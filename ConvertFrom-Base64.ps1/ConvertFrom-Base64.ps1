function ConvertFrom-Base64($string) {
    # Convert the given base64 string back to normal
    [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($string))
}