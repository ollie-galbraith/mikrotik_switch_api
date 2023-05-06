Function Convert-MikrotikPoeHexCodes
    {
        param(
        [ValidateSet('PoEOut','PoELevel','PoEStatus')]
        [Parameter(Mandatory=$true)]
        $Type,
        [Parameter(Mandatory=$true, ParameterSetName='Hex')]
        $Hex,
        [Parameter(Mandatory=$true, ParameterSetName='String')]
        [String]$String
        )

        Switch($Type)
            {
                PoeOut
                    {
                        $Hashtable = @{
                            '0x00' = 'Off'
                            '0x01' = 'On'
                            '0x02' = 'Auto'
                        }
                    }
                PoELevel
                    {
                        $Hashtable = @{
                            '0x00' = 'Auto'
                            '0x01' = 'Low'
                            '0x02' = 'High'
                        }
                    }
                PoEStatus
                    {
                        $Hashtable = @{
                            '0x00' = 'No PoE'
                            '0x02' = 'Waiting for Load'
                            '0x03' = 'Powered On'
                            '0x05' = 'Short Circuit'
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