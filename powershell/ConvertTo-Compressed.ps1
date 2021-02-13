function ConvertTo-Compressed {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(ParameterSetName='Default', Mandatory, Position=0, ValueFromPipeline)]
        [Parameter(ParameterSetName='Remove', Mandatory, Position=0, ValueFromPipeline)]
            [string[]]$Path,

        [Parameter(ParameterSetName='Default', Position=1, ValueFromPipeline)]
        [Parameter(ParameterSetName='Remove', Position=1, ValueFromPipeline)]
        [Alias('T','Target')]
            $TargetDir = '.\', # directory where the new files will be put in

        [Parameter(ParameterSetName='Default', Position=3)]
        [Parameter(ParameterSetName='Remove', Position=3)]
            [string]$TargetPrefix = 'compressed_', # prefix we give to the new files

        [Parameter(ParameterSetName='Default')]
        [Parameter(ParameterSetName='Remove')]
            [switch]$WhatIf, # does everything lke we compressed files, but doesn't write any
        
        [Parameter(ParameterSetName='Default')]
        [Parameter(ParameterSetName='Remove')]
        [switch]$NoBeep, # beeps when finished

        [Parameter(ParameterSetName='Remove', Mandatory)]
        [Alias('R')]
            [switch]$RemoveOriginal, # Deletes original files

        [Parameter(ParameterSetName='Remove')]
        [Alias('Y','Yes','NoConfirm')]
            [switch]$YesRemove # Don't ask confirmation before deleting the files
    )

    BEGIN {

        # creates a temporary directory just so the paths are correct
        if($WhatIf)
        {
            $parentDir = ("$env:TMP\" + $((New-Guid).Guid))
            $TargetDir = ($parentDir + '\' + $TargetDir)
        }
        
        # creates the directory if it doesn't exist
        if(!(Test-Path $TargetDir -PathType Container)) {
            $null = (New-Item -Path $TargetDir -ItemType Directory)
            Write-Verbose "Created directory '$TargetDir'"
        }

        # expands $TargetDir to a DirectoryInfo object
        $TargetDir = (Get-Item $TargetDir)
    }

    PROCESS {

        # if the $Path doesn't match any file
        if(!(Test-Path $Path)) { Write-Warning "No file found with path '$Path'" ; return }

        $Files = @(Get-ChildItem $Path -Attributes !D) # not the directories
        # the '@' forces the array type

        if($Files.Length -eq 0) { Write-Warning "No file found with path '$Path'" ; return }

        # an array with each element being the content of a file
        $bytes = @($Files | % {Get-Content $_ -Raw -AsByteStream})
        
        
        # an array with the new files' informations
        $compressedFiles = @(
            $Files | % {
                New-Object -TypeName PSCustomObject -Property @{
                    FileName = $_.Name
                    CompressedFileName = $_.Name.Replace($_.Name,($TargetDir.FullName + '\' + $TargetPrefix + $_.Name))
                    RawContent = Get-Content $_ -Raw -AsByteStream # bytes
                }
            }
        )

        if(!($WhatIf)) { Clear-Content $compressedFiles.CompressedFileName -ErrorAction Ignore }
        # removes content if file already exists

        $compressedFiles | % {
            $compressedBytes = $(
                
                $cpt = 0 # number of times the current character has appeared so far
                $precByte = $_.RawContent[0]

                $_.RawContent | % {
                    if($_ -eq $precByte) { $cpt ++ }
                    else {
                        # protects the times a character appears > 255 times
                        if($cpt -gt 255)
                        {
                            # '0' is a special flag to say '256', we write it while we have > 255 characters.
                            do {
                                [Byte]('0')
                                $cpt -= 256
                            } while($cpt -gt 255)

                            [Byte]($cpt.ToString())
                        }
                        else {
                            # else, it's a number we can write
                            [Byte]($cpt.ToString())
                        }
                        [Byte]($precByte.ToString())
                        $precByte = $_
                        $cpt = 1
                    }
                }
                
                # we didn't write the last byte (I haven't found a technique to avoid writing it twice)
                if($cpt -gt 255)
                {
                    do {
                        [Byte]('0')
                        $cpt -= 256
                    } while($cpt -gt 255)

                    [Byte]($cpt.ToString())
                }
                else {
                    [Byte]($cpt.ToString())
                }
                [Byte]($precByte.ToString())

            )
            if(!$WhatIf) { Add-Content -Path $_.CompressedFileName -Value $compressedBytes -AsByteStream }
            Write-Verbose ('Done compressing: ' + $_.FileName)
        }
    }

    END {

        Write-Verbose ('Compressed files summary:' + (
            $compressedFiles | Select-Object -Property FileName, CompressedFileName | Out-String))
        # Writes the old names on the left and the new names on the right
        
        if($RemoveOriginal) {
            if(!($WhatIf))
            {
                if($YesRemove) { Remove-Item $Files }
                else { Remove-Item $Files -Confirm }
            }

            Write-Verbose ('Deleted files:' + ($Files | Out-String))
        }

        if($WhatIf) { Remove-Item (Get-Item $parentDir) -Force -Recurse }
        if(!$NoBeep) { [Media.Systemsounds]::Beep.Play() }
    }
}
