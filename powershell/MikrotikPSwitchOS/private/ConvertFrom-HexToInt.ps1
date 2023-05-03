Function ConvertFrom-HexToInt
    {
        <#
        .Synopsis
        Converts hex to an base10 integer
        #>
        
        param(
        [Parameter(Mandatory=$true)]
        $Hex
        )

        $Int = [uint32]$Hex
        Return $Int
    }