Function Get-MikrotikVLANConfig
    {
        <#
        .Synopsis
        Calls the Mikrotik SwitchOS API to retrieve the information about the VLANs configuration (links page http://<switch_address>/index.html#vlans)
        #>

        param(
        [Parameter(Mandatory=$true)]
        [PSCredential]$Credential,
        [Parameter(Mandatory=$false)]
        [URI]$URL
        )

        $Response = Invoke-MikrotikRestMethod -Method Get -URI $URL -Query vlan.b -Credential $Credential

        $Output = Convert-MikrotikVLANConfig -InputObject $Response
        Return $Output
    }