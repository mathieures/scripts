function ConvertTo-Corrupted {
    # Corrupt files by shifting every byte of a certain number of bits
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(ParameterSetName='Default', Mandatory, Position=0, ValueFromPipeline)]
        [Parameter(ParameterSetName='Remove', Mandatory, Position=0, ValueFromPipeline)]
            [string[]]$Path, # The file(s) to corrupt

        [Parameter(ParameterSetName='Default', Position=1)]
        [Parameter(ParameterSetName='Remove', Position=1)]
        [Alias('T','Target')]
            $TargetDir = '.\', # The directory where the new files will be created

        [Parameter(ParameterSetName='Default', Position=2, ValueFromPipeline)]
        [Parameter(ParameterSetName='Remove', Position=2, ValueFromPipeline)]
        [Alias('P')]
        [ValidateRange(0,8)]
            [int]$Power = 1, # The number of bits shifted

        [Parameter(ParameterSetName='Default', Position=3)]
        [Parameter(ParameterSetName='Remove', Position=3)]
            [string]$Prefix = 'corrupted_', # The prefix new files will have. Use `-Prefix ''` to remove.

        [Parameter(ParameterSetName='Default')]
        [Parameter(ParameterSetName='Remove')]
            [switch]$WhatIf, # Do everything but don't create nor remove any file.

        [Parameter(ParameterSetName='Default')]
        [Parameter(ParameterSetName='Remove')]
        [switch]$NoBeep, # No sound played when finished

        [Parameter(ParameterSetName='Default')]
        [Parameter(ParameterSetName='Remove', Mandatory)]
        [Alias('R')]
            [switch]$RemoveOriginal, # Delete original files

        [Parameter(ParameterSetName='Remove')]
        [Alias('Y','Yes','NoConfirmation')]
            [switch]$YesRemove # Don't ask confirmation before deleting the files
    )

    BEGIN {

        # If we don't want to do anything, create a temporary directory just so the paths are correct
        if($WhatIf)
        {
            $parentDir = ("$env:TMP\" + $((New-Guid).Guid))
            $TargetDir = ($parentDir + '\' + $TargetDir)
        }

        # Si le dossier n'existe pas, on le crée.
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
        
        if($Files.Length -eq 0) { Write-Warning "No file found with path '$Path'" ; return }
        # Note: the '@' forces the array type

        # Array containing all the files' content (as bytes)
        $bytes = @($Files | % {Get-Content $_ -Raw -AsByteStream})
        
        # Array containing the new files' names
        $corruptedFiles = @(
            $Files | % {
                New-Object -TypeName PSCustomObject -Property @{
                    FileName = $_.Name
                    CorruptedFileName = $_.Name.Replace($_.Name,($TargetDir.FullName + '\' + $Prefix + $_.Name))
                    RawContent = Get-Content $_ -Raw -AsByteStream # Bytes
                }
            }
        )

        # Remove content if file already exists
        if(!($WhatIf)) { Clear-Content $corruptedFiles.CorruptedFileName -ErrorAction Ignore }

        $corruptedFiles | % {
            $corruptedBytes = $(
                $_.RawContent | % {
                    $binary = [Convert]::ToString($_,2)
                    if($binary.Length -le $Power)
                    {
                        [Convert]::ToByte('0',2) # If too short, convert 0 instead
                    }
                    elseif($binary.Length -gt 8) {
                        [Convert]::ToByte($binary.Substring(0,8),2)
                        # Note: a substring is already a trim so no need to do it with $Power
                    }
                    else {
                        # Trim the last $Power characters from the string and convert the string to a byte
                        [Convert]::ToByte($binary.Substring(0,($binary.Length - $Power)),2)
                        # Or: # [Convert]::ToByte($binary -replace ".{$Power}$",2)
                    }
                }
            )
            if(!$WhatIf) { Add-Content -Path $_.CorruptedFileName -Value $corruptedBytes -AsByteStream }
            Write-Verbose ('Done corrupting: ' + $_.FileName)
        }
    }

    END {

        # Output the original names on the left and the new names on the right
        Write-Verbose ("Corrupted files summary (power $Power):" + (
            $corruptedFiles | Select-Object -Property FileName, CorruptedFileName | Out-String))

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
