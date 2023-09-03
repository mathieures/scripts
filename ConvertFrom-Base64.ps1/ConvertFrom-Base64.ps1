function ConvertFrom-Base64($string) {
    # Convert the given base64 string back to normal
    [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($texte))
}