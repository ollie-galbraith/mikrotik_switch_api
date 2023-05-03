Function Convert-MikrotikLinkSpeed
    {
        <#
        .Synopsis
        Converts the Mikrotik API output from hex to link speeds (in double)
        #>
        
        param(
        [Parameter(Mandatory=$true)]
        $Hex
        )
        
        $SwOSLinkSpeeds = @{
            '0x01' = 0.1
            '0x02' = 1.0
            '0x07' = 0.0
            '0x04' = 0.0
            '0x03' = 10.0
        }

        ForEach($Speed in $SwOSLinkSpeeds.GetEnumerator())
            {
                If($Speed.Key -eq $Hex)
                    {
                        Return $Speed.Value
                    }
            }
    }