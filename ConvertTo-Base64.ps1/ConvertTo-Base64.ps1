function ConvertTo-Base64($string) {
    # Convert the given string to base64
    [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($string))
}