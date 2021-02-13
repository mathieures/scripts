function ConvertFrom-Compressed {
    # Uncompress a file compressed with the ConvertTo-Compressed() function
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
            [string[]]$Path,

        [Alias('T','Target')]
            $TargetDir = '.\', # Directory where the new files will be put in

            [string]$Prefix = 'compressed_', # Prefix we take off the old files
            [string]$TargetPrefix = 'decompressed_', # Prefix we give to the new files
            [switch]$WhatIf, # Do everything but don't create any nor remove any file.
            [switch]$NoBeep # No sound played when finished
    )

    BEGIN {
        
        if(!($TargetDir.EndsWith('\'))) { $TargetDir = ($TargetDir + '\') }
        
        # If we don't want to do anything, create a temporary directory just so the paths are correct
        if($WhatIf)
        {
            $parentDir = ("$env:TMP\" + $((New-Guid).Guid))
            $TargetDir = ($parentDir + '\' + $TargetDir)
        }
        
        # Create the directory if it doesn't exist
        if(!(Test-Path $TargetDir -PathType Container)) {
            $null = (New-Item -Path $TargetDir -ItemType Directory)
            Write-Verbose "Created directory '$TargetDir'"
        }

        # Expand $TargetDir to a DirectoryInfo object
        $TargetDir = (Get-Item $TargetDir)
    }

    PROCESS {

        # If the $Path doesn't match any file
        if(!(Test-Path $Path)) { Write-Warning "No file found with path '$Path'" ; return }

        $Files = @(Get-ChildItem $Path -Attributes !D) # Not the directories
        # Note: the '@' forces the array type

        if($Files.Length -eq 0) { Write-Warning "No file found with path '$Path'" ; return }

        # An array with each element being the content of a file
        $bytes = @($Files | % {Get-Content $_ -Raw -AsByteStream})
        
        # An array with the new files' informations
        $decompressedFiles = @(
            $Files | % {
                New-Object -TypeName PSCustomObject -Property @{
                    FileName = $_.Name
                    DecompressedFileName = ($TargetDir.FullName + '\' + $TargetPrefix + $_.Name.Replace($Prefix,''))
                    RawContent = Get-Content $_ -Raw -AsByteStream # Bytes
                }
            }
        )

        # Remove content if file already exists
        if(!($WhatIf)) { Clear-Content $decompressedFiles.DecompressedFileName -ErrorAction Ignore }

        $decompressedBytes = [System.Collections.Generic.List[Byte]]::new()
        $decompressedFiles | % {
            $nb = $true # Tells if we're reading the number of characters or the character
            $cpt = 0 # The number of characters
            $wasZero = $false
            $zeros = 0 # Number of 0's in a row

            $_.RawContent | % {
                # Actual algorithm:
                if($nb){
                    # If 0, we don't know the number yet; we need to loop.
                    if($_ -eq '0')
                    {
                        $wasZero = $true
                        $zeros++
                        $nb = $false # To re-enable the check on the next turn
                    }
                    else {
                        # If it is not 0 and it wasZero, we have the total number of 0's now.
                        if($wasZero)
                        {
                            $cpt = $zeros * 256 + $_
                            $wasZero = $false
                            $zeros = 0
                        }
                        # If it wasn't, we directly have the cpt.
                        else { $cpt = $_ }
                    }
                }
                else {
                    # 1 at a time because bytes are between 0 and 255 (ie. we can't 'Add($_ * $cpt)')
                    for($i = 0; $i -lt $cpt; $i++) {
                        $decompressedBytes.Add($_)
                    }
                }
                $nb = !($nb)
            }

            if(!$WhatIf) { Add-Content -Path $_.DecompressedFileName -Value $decompressedBytes -AsByteStream }
            Write-Verbose ('Done decompressing: ' + $_.FileName)
            $decompressedBytes.Clear()
        }
    }
    
    END {

        # Output the old names on the left and the new names on the right
        Write-Verbose ('Decompressed files summary:' + (
            $decompressedFiles | Select-Object -Property FileName, DecompressedFileName | Out-String))

        if($WhatIf) { Remove-Item (Get-Item $parentDir) -Force -Recurse }
        if(!$NoBeep) { [Media.Systemsounds]::Beep.Play() }
    }
}
