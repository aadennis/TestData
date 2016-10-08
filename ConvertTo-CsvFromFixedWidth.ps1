<# 
.Synopsis 
    PRIVATE
    Given a single passed record, used the spec detail to work out the csv equivalent
    record to return.
.Description
    This is intended to be a private function
.Example 
    Get-CsvRecord -columnCount $noOfColumns -record $record -spec $spec
#>
function Get-CsvRecord($columnCount, $record, $spec) {
     $outputRecord = [string]::Empty
     1..$columnCount | % { 
        # new column starts...
        $currentColumn = $_  -1
        $currentColDef = $spec.FriendsSpec.Fields[$currentColumn]
        $outputRecord += $($record.substring($currentColDef.pos, $currentColDef.length)).trim() + ","

     }
     return $outputRecord
}

# PRIVATE
function ConvertTo-ObjectFromJson($filePath) {
    $temp = Get-Content -Raw $filePath
    return  $temp | ConvertFrom-Json
}

<# 
.Synopsis 
    PUBLIC
    Given a fixed width data file, and a json spec containing the formatting rules,
    output a CSV version of the file. 
    It is assumed right now that the data starts at line 3
.Example 
    ConvertTo-CsvFromFixedWidth -fixedWidthSpecFile ".\RealFriendsSpec.json" -fixedWidthDataFile ".\FWFile001.txt" -Verbose
#>
function ConvertTo-CsvFromFixedWidth {
	[CmdletBinding()]
	Param (
    [string][Parameter(mandatory)]
	$fixedWidthSpecFile,
    [string][Parameter(mandatory)]
	$fixedWidthDataFile,
    [string][Parameter(mandatory)]
	$outputFile
	)
	Begin {
        # Mock Get-Process{}
        $spec = ConvertTo-ObjectFromJson $fixedWidthSpecFile
        $noOfColumns = $spec.FriendsSpec.Fields.Count
        $outputRecords = @()
    }
	Process {
        Get-Content $fixedWidthDataFile  | select -Skip 2 | foreach {
            # new record starts...
            $record = $_
            $outputRecords += Get-CsvRecord -columnCount $noOfColumns -record $record -spec $spec
        }
        Write-Verbose "Count of records created: [$($outputRecords.Count)]"
	}
	End {
        
        $outputRecords | Out-File $outputFile
        Write-Verbose "Output csv is: [$outputFile]"
	}
}

# the test files are taken from here [https://github.com/aadennis/TestData]
Describe "Data file format conversion tests" {
    It "converts a set of records from fixed width to csv" {
        $tempFile = [System.IO.Path]::GetTempFileName()
        ConvertTo-CsvFromFixedWidth -fixedWidthSpecFile ".\RealFriendsSpec.json" -fixedWidthDataFile ".\FWFile001.txt" -outputFile $tempFile
        $csvRecordSet = Get-Content -Path $tempFile
        $csvRecordSet.Length | Should be 1000
        $csvRecordSet[0].Length | Should be 53
        $csvRecordSet[333] | Should be "334,Marie,Gray,mgray99@godaddy.com,Female,193.122.103.129,"
    }
}






