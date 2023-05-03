Function ConvertFrom-HexToBinary
    {
        <#
        .Synopsis
        Converts a hex to binary
        #>
        
        param(
        [Parameter(Mandatory=$true)]
        $Hex,
        [Parameter(Mandatory=$true)]
        [int]$PadLength
        )
        
        If($Hex -like "0x*")
            {
                $Hex = $Hex.Replace("0x",'')
            }

        [byte[]]$Bytes = ($Hex -split '(.{2})' -ne '' -replace '^', '0x')

        ForEach($Byte in $Bytes)
            {
                $Binary += "$([string]([Convert]::ToString($Byte, 2)).PadLeft(8,'0'))"
            }
        $Binary = $Binary.TrimStart('0')
        $Binary = $Binary.PadLeft($PadLength,'0')
        Return $Binary
    }
