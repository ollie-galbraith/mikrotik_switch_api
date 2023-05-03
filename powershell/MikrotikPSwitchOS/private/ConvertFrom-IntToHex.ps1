Function ConvertFrom-IntToHex
    {
        <#
        .Synopsis
        Converts a integer to hex
        #>

        param(
        [Parameter(Mandatory=$true)]
        [Int]$Int,
        [Parameter(Mandatory=$true)]
        [Int]$PadLength
        )

        [string]$Hex = '{0:X}' -f $Int
        $Padded = $Hex.PadLeft($PadLength, '0')
        $Hex = "0x$Padded"
        Return $Hex
    }