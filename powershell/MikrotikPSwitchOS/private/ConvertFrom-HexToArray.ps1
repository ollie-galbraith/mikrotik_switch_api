Function ConvertFrom-HexToArray
    {
        <#
        .Synopsis
        Converts a the Mikrotik hex to a boolean array 
        #>
        
        param(
        [Parameter(Mandatory=$true)]
        [String]$Hex,
        [Parameter(Mandatory=$true)]
        [int]$ArrayLength
        )

        $Binary = ConvertFrom-HexToBinary -Hex $Hex -PadLength $ArrayLength
        $Output = @()
        [Array]$CharArray = ($Binary[-1..-$Binary.Length] -join '').ToCharArray()
        ForEach($Item in $CharArray)
            {
                $Result = $true
                If($Item -eq '0')
                    {
                        $Result = $false
                    }
                [array]$Output += $Result
            }
        Return $Output
    }