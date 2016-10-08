<# 
.Synopsis 
    Given a fixed width data file, and a json spec containing the formatting rules,
    output a CSV version of the file. 
    It is assumed right now that the data starts at line 3
.Example 
    ConvertTo-CsvFromFixedWidth -fixedWidthSpecFile ".\RealFriendsSpec.json" -fixedWidthDataFile ".\FWFile001.txt" -Verbose
#>
function ConvertTo-CsvFromFixedWidth {
	[CmdletBinding(SupportsShouldProcess)]
	Param (
    [string][Parameter(mandatory)]
	$fixedWidthSpecFile,
    [string][Parameter(mandatory)]
	$fixedWidthDataFile
	)
	Begin {
        $specAsJson = Get-Content -Raw $fixedWidthSpecFile
        $spec = $specAsJson | ConvertFrom-Json
        $noOfColumns = $spec.FriendsSpec.Fields.Count
        $outputRecords = @()
    }
	Process {
        Get-Content $fixedWidthDataFile  | select -Skip 2 | foreach {
            # new record starts...
            $record = $_
            $outputRecord = [string]::Empty
            1..$noOfColumns | % { 
                # new column starts...
                $currentColumn = $_  -1
                $currentColDef = $spec.FriendsSpec.Fields[$currentColumn]
                $outputRecord += $($record.substring($currentColDef.pos, $currentColDef.length)).trim() + ","
            }
            $outputRecords += $outputRecord
        }
        $outputRecords.Count
	}
	End {
        $outputFile = [System.IO.Path]::GetTempFileName()
        $outputRecords | Out-File $outputFile
        Write-Verbose "Output csv is: [$outputFile]"
	}
}

