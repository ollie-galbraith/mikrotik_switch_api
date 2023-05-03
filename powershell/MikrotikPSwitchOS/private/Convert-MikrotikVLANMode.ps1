Function Convert-MikrotikVLANMode
    {
        <#
        .Synopsis
        Converts the Mikrotik API output from hex to VLAN modes (string)
        #>

        param(
        [Parameter(Mandatory=$true, ParameterSetName='Hex')]
        $Hex,
        [Parameter(Mandatory=$true, ParameterSetName='String')]
        [String]$String
        )
        
        $SwOSVLANModes = @{
            '0x00' = 'Disabled'
            '0x01' = 'Optional'
            '0x02' = 'Enabled'
            '0x03' = 'Strict'
        }

        ForEach($VLAN in $SwOSVLANModes.GetEnumerator())
            {
                If($Hex -ne '')
                    {
                        If($VLAN.Key -eq $Hex)
                            {
                                Return $VLAN.Value
                            }
                    }
                If($String -ne '')
                    {
                        If($VLAN.Value -eq $String)
                            {
                                Return $VLAN.Key
                            }
                    }
            }
    }