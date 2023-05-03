Function Get-MikrotikTotalPorts
    {
        <#
        .Synopsis
        Returns the total number of ports 
        #>
        
        param(
        [Parameter(Mandatory=$true)]
        [PSCredential]$Credential,
        [Parameter(Mandatory=$false)]
        [URI]$URL
        )

        $Response = Invoke-MikrotikRestMethod -Method Get -URI $URL -Query link.b -Credential $Credential
        $Output = [uint32]$Response.prt
        Return $Output
    }