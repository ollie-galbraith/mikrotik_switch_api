Function Get-MikrotikPoE
    {
        param(
        [Parameter(Mandatory=$true)]
        [PSCredential]$Credential,
        [Parameter(Mandatory=$false)]
        [URI]$URL
        )

        $Links = Get-MikrotikLinks -Credential $Credential -URL $URL

        $Response = Invoke-MikrotikRestMethod -Method Get -URI $URL -Credential $Credential -Query poe.b
        $TotalPorts = Get-MikrotikTotalPorts -Credential $Credential -URL $URL
        $Output = Convert-MikrotikPoE -InputObject $Response -Links $Links -TotalPorts $TotalPorts

        Return $Output
    }
