Function Get-MikrotikLinks
    {
        <#
        .Synopsis
        Calls the Mikrotik SwitchOS API to retrieve the information about the switch ports (links page http://<switch_address>/index.html#link)
        #>
        
        param(
        [Parameter(Mandatory=$true)]
        [PSCredential]$Credential,
        [Parameter(Mandatory=$false)]
        [URI]$URL,
        [Parameter(Mandatory=$false)]
        [ValidateSet('rj45','sfp')]
        [String]$Type
        )

        #Runs main rest method
        $Response = Invoke-MikrotikRestMethod -Method Get -URI $URL -Query link.b -Credential $Credential
        
        #Retrieves the total amount of ports on the switch, helps with calculating the link parameters
        $TotalPorts = Get-MikrotikTotalPorts -Credential $Credential -URL $URL

        #Uses the JSON retrieved from $Response, and converts it from hex/binary to human readable information
        $Output = Convert-MikrotikLinks -InputObject $Response -TotalPorts $TotalPorts
        If($Type -ne '')
            {
                Return $Output | Where-Object PortType -eq $Type
            }
        Else
            {
                Return $Output
            }
    }