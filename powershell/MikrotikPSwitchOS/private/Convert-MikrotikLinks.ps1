Function Convert-MikrotikLinks
    {
        <#
        .Synopsis
        Converts the Mikrotik API link page output from hex to boolean arrays/plain text 
        #>
        
        param(
        [PSCustomObject]$InputObject,
        [Int]$TotalPorts
        )

        $Ports = $InputObject.nm.count 
        $PortNumber = 0

        [array]$EnabledPorts = ConvertFrom-HexToArray -Hex $InputObject.en -ArrayLength $TotalPorts
        [array]$AutoNegPorts = ConvertFrom-HexToArray -Hex $InputObject.an -ArrayLength $TotalPorts
        [array]$DuplexPorts = ConvertFrom-HexToArray -Hex $InputObject.dpx -ArrayLength $TotalPorts
        [array]$LinkPorts = ConvertFrom-HexToArray -Hex $InputObject.lnk -ArrayLength $TotalPorts

        $TotalPorts = [uint32]$InputObject.prt
        $RJ45Ports = [uint32]$InputObject.sfpo

        [System.Collections.ArrayList]$Output = @()
        While($PortNumber -le ($Ports - 1))
            {
                [double]$LinkSpeed = "$(Convert-MikrotikLinkSpeed -Hex $InputObject.spd[$PortNumber])"
                If(($PortNumber -lt $RJ45Ports) -or ($LinkSpeed -le 0.1))
                    {
                        $Type = "rj45"
                    }
                If(($PortNumber -ge $RJ45Ports) -and (($LinkSpeed -eq 0) -or ($LinkSpeed -gt 0.1)))
                    {
                        $Type = 'sfp'
                    }
                $PortOptions = [pscustomObject]@{
                    Enabled = $EnabledPorts[$PortNumber]
                    PortNumber = $PortNumber + 1
                    PortType = $Type
                    PortName = "$(ConvertFrom-HexToString -Hex $InputObject.nm[$PortNumber])"
                    LinkSpeed = $LinkSpeed
                    LinkActive = $LinkPorts[$PortNumber]
                    AutoNeg = $AutoNegPorts[$PortNumber]
                    FullDuplex = $DuplexPorts[$PortNumber]
                }
                [void]$Output.Add($PortOptions)
                $PortNumber += 1
            }
        Return $Output
    }