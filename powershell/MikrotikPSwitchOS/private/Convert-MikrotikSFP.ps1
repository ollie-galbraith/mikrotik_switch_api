Function Convert-MikrotikSFP
    {
        <#
        .Synopsis
        Converts the Mikrotik API SPF pages output from hex to boolean arrays/plain text 
        #>

        param(
        [PSCustomObject]$InputObject,
        [PSCustomObject]$Links
        )

        $Ports = $Links.count 
        $PortNumber = 0

        [System.Collections.ArrayList]$Output = @()
        While($PortNumber -le ($Ports - 1))
            {
                [int64]$Temp = "$([uint32]$InputObject.tmp[$PortNumber])"
                [double]$Voltage = "$((([uint32]$InputObject.vcc[$PortNumber]).ToString()).Insert(1,'.'))"

                If($Temp -gt 150)
                    {
                        $Temp = $null
                    }
                If($Voltage -gt 5.0)
                    {
                        $Voltage = $null
                    }

                $PortOptions = [pscustomObject]@{
                    PortNumber = $Links[$PortNumber].PortNumber
                    PortName = $Links[$PortNumber].PortName
                    Vendor = "$(ConvertFrom-HexToString -Hex $InputObject.vnd[$PortNumber])"
                    PartNumber = "$(ConvertFrom-HexToString -Hex $InputObject.pnr[$PortNumber])"
                    Serial = "$(ConvertFrom-HexToString -Hex $InputObject.ser[$PortNumber])"
                    Type = "$(ConvertFrom-HexToString -Hex $InputObject.typ[$PortNumber])"
                    Temp = $Temp
                    Voltage = $Voltage
                }
                [void]$Output.Add($PortOptions)
                $PortNumber += 1
            }
        Return $Output
    }