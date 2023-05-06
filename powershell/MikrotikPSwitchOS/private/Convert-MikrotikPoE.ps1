Function Convert-MikrotikPoE
    {
        <#
        .Synopsis
        Converts the Mikrotik API PoE page output from hex to boolean arrays/plain text 
        #>
        
        param(
        [PSCustomObject]$InputObject,
        [PSCustomObject]$Links,
        [int]$TotalPorts
        )
        
        $Ports = $Links.count
        $PortNumber = 0

        [System.Collections.ArrayList]$Output = @()
        While($PortNumber -le ($Ports - 1))
            {
                $Current = "$(ConvertFrom-HexToInt -Hex $InputObject.curr[$PortNumber])"
                [double]$DecimalCurrent = $Current.Insert(($Current.Length -1), '.')

                $Voltage = "$(ConvertFrom-HexToInt -Hex $InputObject.volt[$PortNumber])"
                [double]$DecimalVoltage = $Voltage.Insert(($Voltage.Length -1), '.')

                $Power = "$(ConvertFrom-HexToInt -Hex $InputObject.pwr[$PortNumber])"
                [double]$DecimalPower = $Power.Insert(($Power.Length -1), '.')

                $PortOptions = [pscustomObject]@{
                    PortNumber = $Links[$PortNumber].PortNumber
                    PortName = $Links[$PortNumber].PortName
                    PoEOut = "$(Convert-MikrotikPoeHexCodes -Type PoEOut -Hex $InputObject.poe[$PortNumber])"
                    PoEPriority =  ConvertFrom-HexToInt -Hex $InputObject.prio[$PortNumber]
                    VoltageLevel =  Convert-MikrotikPoeHexCodes -Type PoELevel -Hex $InputObject.lvl[$PortNumber]
                    Status = Convert-MikrotikPoeHexCodes -Type PoEStatus -Hex $InputObject.poes[$PortNumber]
                    Current = "$DecimalCurrent`mA"
                    Voltage = "$DecimalVoltage`V"
                    Power = "$DecimalPower`W"
                }
                [void]$Output.Add($PortOptions)
                $PortNumber += 1
            }
        Return $Output
    }