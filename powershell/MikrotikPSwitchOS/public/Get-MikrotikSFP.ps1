Function Get-MikrotikSFP
    {
        <#
        .Synopsis
        Calls the Mikrotik SwitchOS API to retrieve the information about the switch SFP ports (links page http://<switch_address>/index.htmll#sfp)
        #>
        
        param(
        [Parameter(Mandatory=$true)]
        [PSCredential]$Credential,
        [Parameter(Mandatory=$false)]
        [URI]$URL
        )

        $Links = Get-MikrotikLinks -Credential $Credential -URL $URL -Type sfp

        $Response = Invoke-MikrotikRestMethod -Method Get -URI $URL -Query sfp.b -Credential $Credential
        $Output = Convert-MikrotikSFP -InputObject $Response -Links $Links
        Return $Output
    }
