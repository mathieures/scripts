function ConvertTo-Corrupted {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(ParameterSetName='Default', Mandatory, Position=0, ValueFromPipeline)]
        [Parameter(ParameterSetName='Remove', Mandatory, Position=0, ValueFromPipeline)]
            [string[]]$Path,

        [Parameter(ParameterSetName='Default', Position=1)]
        [Parameter(ParameterSetName='Remove', Position=1)]
        [Alias('T','Target')]
            $TargetDir = '.\',

        [Parameter(ParameterSetName='Default', Position=2, ValueFromPipeline)]
        [Parameter(ParameterSetName='Remove', Position=2, ValueFromPipeline)]
        [Alias('P')]
        [ValidateRange(0,8)]
            [int]$Power = 1,

        [Parameter(ParameterSetName='Default', Position=3)]
        [Parameter(ParameterSetName='Remove', Position=3)]
            [string]$Prefix = 'corrupted_',

        [Parameter(ParameterSetName='Default')]
        [Parameter(ParameterSetName='Remove')]
            [switch]$WhatIf, # does everything lke we compressed files, but doesn't write any

        [Parameter(ParameterSetName='Default')]
        [Parameter(ParameterSetName='Remove', Mandatory)]
        [Alias('R')]
            [switch]$RemoveOriginal, # Deletes original files

        [Parameter(ParameterSetName='Default')]
        [Parameter(ParameterSetName='Remove')]
        [switch]$NoBeep, # beeps when finished

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

        # si le dossier n'existe pas, on le crée.
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
        
        if($Files.Length -eq 0) { Write-Warning "No file found with path '$Path'" ; return }
        # the '@' forces the array type

        # un array avec le contenu de chaque fichier en binaire
        $bytes = @($Files | % {Get-Content $_ -Raw -AsByteStream})
        
        # array contenant le nom des nouveaux fichiers
        $corruptedFiles = @(
            $Files | % {
                New-Object -TypeName PSCustomObject -Property @{
                    FileName = $_.Name
                    CorruptedFileName = $_.Name.Replace($_.Name,($TargetDir.FullName + '\' + $Prefix + $_.Name))
                    RawContent = Get-Content $_ -Raw -AsByteStream # bytes
                }
            }
        )

        if(!($WhatIf)) { Clear-Content $corruptedFiles.CorruptedFileName -ErrorAction Ignore }
        # removes content if file already exists

        $corruptedFiles | % {
            $corruptedBytes = $(
                $_.RawContent | % {
                    $binary = [Convert]::ToString($_,2)
                    if($binary.Length -le $Power)
                    {
                        [Convert]::ToByte('0',2) # if too short, converts 0 instead
                    }
                    elseif($binary.Length -gt 8) {
                        [Convert]::ToByte($binary.Substring(0,8),2)
                        # a substring is already a trim so no need to do it with $Power
                    }
                    else {
                        [Convert]::ToByte($binary.Substring(0,($binary.Length - $Power)),2)
                        # or: # [Convert]::ToByte($binary -replace ".{$Power}$",2)
                        # trims the last $Power characters from the string and converts the string to a byte
                    }
                }
            )
            if(!$WhatIf) { Add-Content -Path $_.CorruptedFileName -Value $corruptedBytes -AsByteStream }
            Write-Verbose ('Done corrupting: ' + $_.FileName)
        }
    }

    END {

        Write-Verbose ("Corrupted files summary (power $Power):" + (
            $corruptedFiles | Select-Object -Property FileName, CorruptedFileName | Out-String))
        # affiche les noms des fichiers à gauche et les nouveaux noms à droite
        
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
