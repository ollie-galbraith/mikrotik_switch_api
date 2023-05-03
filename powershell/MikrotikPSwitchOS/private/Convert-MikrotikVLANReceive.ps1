Function Convert-MikrotikVLANReceive
    {
        <#
        .Synopsis
        Converts the Mikrotik API link page output from hex to VLAN recieve modes 
        #>
        
        param(
        [Parameter(Mandatory=$true, ParameterSetName='Hex')]
        $Hex,
        [Parameter(Mandatory=$true, ParameterSetName='String')]
        [String]$String
        )
        
        $SwOSVLANModes = @{
            '0x00' = 'Any'
            '0x01' = 'Only Tagged'
            '0x02' = 'Only Untagged'
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