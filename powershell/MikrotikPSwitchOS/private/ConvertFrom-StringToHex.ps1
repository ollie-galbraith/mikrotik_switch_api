Function ConvertFrom-StringToHex
    {
        <#
        .Synopsis
        Converts a string to hex
        #>

        param(
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [string]$String
        )

        $Hex = ''
        $CharArray = $String.ToCharArray()
        Foreach ($Char in $CharArray) 
            {
                $Hex = $Hex + [System.String]::Format("{0:X2}", [System.Convert]::ToUInt32($Char))
            }
        Return $Hex
    }