echo "$*" | sed 's;\\;/;g' | sed -r 's;([A-Z]):;/mnt/\l\1;'
# Convert backslashes to slashes, and add '/mnt/[lowercase disk letter]' at the beginning
# e.g.: C:\Users\johndoe -> /mnt/c/Users/johndoe