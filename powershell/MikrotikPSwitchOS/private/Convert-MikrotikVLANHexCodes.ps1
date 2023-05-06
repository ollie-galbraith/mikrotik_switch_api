Function Convert-MikrotikVLANHexCodes
    {
        param(
        [ValidateSet('VLANMode','VLANReceive')]
        [Parameter(Mandatory=$true)]
        $Type,
        [Parameter(Mandatory=$true, ParameterSetName='Hex')]
        $Hex,
        [Parameter(Mandatory=$true, ParameterSetName='String')]
        [String]$String
        )

        Switch($Type)
            {
                VLANMode
                    {
                        $Hashtable = @{
                            '0x00' = 'Disabled'
                            '0x01' = 'Optional'
                            '0x02' = 'Enabled'
                            '0x03' = 'Strict'
                        }
                    }
                VLANReceive
                    {
                        $Hashtable = @{
                            '0x00' = 'Any'
                            '0x01' = 'Only Tagged'
                            '0x02' = 'Only Untagged'
                        }
                    }
            }
        ForEach($Code in $Hashtable.GetEnumerator())
            {
                If($Hex -ne '')
                    {
                        If($Code.Key -eq $Hex)
                            {
                                Return $Code.Value
                            }
                    }
                If($String -ne '')
                    {
                        If($Code.Value -eq $String)
                            {
                                Return $Code.Key
                            }
                    }
            }
    }