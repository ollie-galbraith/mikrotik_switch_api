Function Convert-MikrotikVLANConfig
    {
        <#
        .Synopsis
        Converts the Mikrotik API VLANs page output from hex to boolean arrays/plain text 
        #>
        
        param(
        [PSCustomObject]$InputObject,
        [Int]$TotalPorts
        )

        [System.Collections.ArrayList]$Output = @()
        $VLAN_Instance = 0
        ForEach($VLANItem in $InputObject)
            {
                #[array]$EnabledPorts = ConvertFrom-HexToArray -Hex $InputObject.en
                $Object = [pscustomobject]@{
                    VLANID = [uint32]$InputObject.vid[$VLAN_Instance]
                    PortIsolation = [uint32]$InputObject.piso[$VLAN_Instance]
                    Learning = [uint32]$InputObject.lrn[$VLAN_Instance]
                    Mirror = [uint32]$InputObject.mrr[$VLAN_Instance]
                    IMGP_Snoop = [uint32]$InputObject.igmp[$VLAN_Instance]
                    Members = ConvertFrom-HexToArray -Hex $InputObject.mbr[$VLAN_Instance] -ArrayLength $TotalPorts
                }
                [void]$Output.Add($Object)

                $VLAN_Instance += 1
            }
        Return $Output
    }