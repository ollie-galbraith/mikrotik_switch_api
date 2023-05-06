Function Convert-MikrotikVLAN
    {
        <#
        .Synopsis
        Converts the Mikrotik API VLAN page output from hex to boolean arrays/plain text 
        #>
        
        param(
        [PSCustomObject]$InputObject,
        [PSCustomObject]$Links,
        [int]$TotalPorts
        )
        
        $Ports = $Links.count
        $PortNumber = 0

        [array]$ForceVLAN = ConvertFrom-HexToArray -Hex $InputObject.fvid -ArrayLength $TotalPorts

        [System.Collections.ArrayList]$Output = @()
        While($PortNumber -le ($Ports - 1))
            {
                $PortOptions = [pscustomObject]@{
                    PortNumber = $Links[$PortNumber].PortNumber
                    PortName = $Links[$PortNumber].PortName
                    VLANMode = "$(Convert-MikrotikVLANHexCodes -Type VLANMode -Hex $InputObject.vlan[$PortNumber])"
                    VLANReceive = "$(Convert-MikrotikVLANHexCodes -Type VLANReceive -Hex $InputObject.vlni[$PortNumber])"
                    VLANID = ConvertFrom-HexToInt -Hex $InputObject.dvid[$PortNumber]
                    ForceVLANID = $ForceVLAN[$PortNumber]
                }
                [void]$Output.Add($PortOptions)
                $PortNumber += 1
            }
        Return $Output
    }