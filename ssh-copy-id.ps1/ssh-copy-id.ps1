# Equivalent (with less features) of the ssh-copy-id from Linux-based systems
# Thanks to Augie Gardner https://serverfault.com/a/583659/1003865
param(
    [Parameter(mandatory=$true)]
    [String] $Destination
)

Get-Content ~/.ssh/id_rsa.pub | ssh $Destination "mkdir ~/.ssh 2>/dev/null ; cat >> ~/.ssh/authorized_keys"