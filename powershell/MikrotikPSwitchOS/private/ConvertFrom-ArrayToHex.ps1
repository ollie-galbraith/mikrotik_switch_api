Function ConvertFrom-ArrayToHex
    {
        <#
        .Synopsis
        Converts a boolean array to hex
        #>
        
        param(
        [Parameter(Mandatory=$true)]
        [Array]$Array
        )

        [string]$BinaryString = ''
        [array]::Reverse($Array)
        ForEach($Item in $Array)
            {
                If($Item -eq $true)
                    {
                        $Binary = '1'
                    }
                ElseIf($Item -eq $false)
                    {
                        $Binary = '0'
                    }
                $BinaryString += $Binary
            }

        $Hex = ("0x$(([Convert]::ToUInt32($BinaryString, 2)).ToString('X').PadLeft(8,'0'))").ToLower()
        Return $Hex
    }