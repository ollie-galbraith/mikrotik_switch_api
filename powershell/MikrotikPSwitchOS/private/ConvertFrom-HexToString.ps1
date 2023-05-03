Function ConvertFrom-HexToString
    {
        <#
        .Synopsis
        Converts hex to a string
        #>
        
        param(
        [Parameter(Mandatory=$true)]
        $Hex
        )

        If($Hex -like "0x*")
            {
                $Hex = $Hex.Replace("0x",'')
            }

        [string]$String = ''
        $Hex -split '(.{2})' -ne '' | ForEach-Object {
            $String += [char][byte]"0x$_"
        }

        Return $String 
    }