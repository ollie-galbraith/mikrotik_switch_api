Function ConvertFrom-MikrotikToJson
    {
        <#
        .Synopsis
        Converts the non-standard JSON output from the Mikrotik API into parsable JSON to be imported into Powershell for later use
        #>
        
        param(
        [Parameter(Mandatory=$true)]
        [string]$InputObject
        )

        $JsonDump = $InputObject

        $WordRegex = '(\w+)'
        $SingleQuoteRegex = "(\')"
        $DoubleDoubleQuoteRegex = '\"{2}(\w+)\"{2}'

        $FixedJson = $JsonDump -replace $SingleQuoteRegex, '"'
        $FixedJson = $FixedJson -replace $WordRegex,'"$1"'
        $FixedJson = $FixedJson -replace $DoubleDoubleQuoteRegex, '"$1"'

        $FixedJson = $FixedJson -replace "],}","]}"
        If($FixedJson -like "*,")
            {
            }
        Try
            {
                $JsonObject = $FixedJson | ConvertFrom-Json
            }
        Catch
            {
                $FixedJson | Set-Clipboard
                Return "Failed JSON conversion sent to clipboard"
            }
        Return $JsonObject
    }