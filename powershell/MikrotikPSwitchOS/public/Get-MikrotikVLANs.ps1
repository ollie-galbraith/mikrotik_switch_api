Function Get-MikrotikVLANs
    {
        <#
        .Synopsis
        Calls the Mikrotik SwitchOS API to retrieve the information about the VLAN configuration (links page http://<switch_address>/index.html#vlan)
        #>
        
        param(
        [Parameter(Mandatory=$true)]
        [PSCredential]$Credential,
        [Parameter(Mandatory=$false)]
        [URI]$URL
        )

        $Links = Get-MikrotikLinks -Credential $Credential -URL $URL

        $Response = Invoke-MikrotikRestMethod -Method Get -URI $URL -Query fwd.b -Credential $Credential
        $TotalPorts = Get-MikrotikTotalPorts -Credential $Credential -URL $URL
        $Output = Convert-MikrotikVLAN -InputObject $Response -Links $Links -TotalPorts $TotalPorts
        Return $Output
    }