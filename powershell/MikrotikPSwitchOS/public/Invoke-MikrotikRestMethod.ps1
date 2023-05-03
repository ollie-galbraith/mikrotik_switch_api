Function Invoke-MikrotikRestMethod
    {
        <#
        .Synopsis
        Sends a Rest Method request to the Mikrotik SwitchOS API
        #>
        
        param(
        [Parameter(Mandatory=$True)]
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method,
        [Parameter(Mandatory=$True)]
        [URI]$URI,
        [Parameter(Mandatory=$True)]
        [String]$Query,
        [Parameter(Mandatory=$true)]
        [PSCredential]$Credential,
        [Parameter(Mandatory=$False)]
        [String]$Body,
        [Parameter(Mandatory=$false)]
        [Switch]$NoConversion
        )

        Begin
            {
                $NetAssembly = [Reflection.Assembly]::GetAssembly([System.Net.Configuration.SettingsSection])
                If($NetAssembly)
                    {
                        $BindingFlags = [Reflection.BindingFlags] "Static,GetProperty,NonPublic"
                        $SettingsType = $netAssembly.GetType("System.Net.Configuration.SettingsSectionInternal")

                        $Instance = $SettingsType.InvokeMember("Section", $bindingFlags, $null, $null, @())
                        If($Instance)
                            {
                                $BindingFlags = "NonPublic","Instance"
                                $UseUnsafeHeaderParsingField = $SettingsType.GetField("useUnsafeHeaderParsing", $bindingFlags)
                                If($UseUnsafeHeaderParsingField)
                                    {
                                        $UseUnsafeHeaderParsingField.SetValue($instance, $true)
                                    }
                            }
                    }
            }

        Process
            {

                [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} 

                $Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
                $Headers.Add("Accept", "*/*")
                $Headers.Add("Accept-Language", "en-US,en;q=0.5")
                $Headers.Add("Accept-Encoding", "gzip, deflate")
                $Headers.Add("Content-Type", "text/plain")
                $Headers.Add("Origin", "$URI")
                $Headers.Add("Referer", "$URI/index.html")

                $URI = "$URI" + $Query

                $InvokeParams = @{
                    Uri = $URI
                    Method = $Method   
                    Credential = $Credential
                    Headers = $Headers
                }

                If($Method -eq 'POST')
                    {
                        If($Body -eq '')
                            {
                                Write-Error "Unable to send POST request with no body"
                                Break
                            }
                        [void]$InvokeParams.Add('Body',$Body)
                    }

                $Response = (Invoke-WebRequest @InvokeParams -ErrorAction SilentlyContinue).Content
            }
        End
            {
                #Allows for troubleshooting, it will spit out the plaintext response for the API, instead of the response converted to proper JSON
                If($NoConversion -eq $true)
                    {
                        $InitalObject = $Response
                    }
                Else
                    {
                        $InitalObject = ConvertFrom-MikrotikToJson -InputObject $Response
                    }
                Return $InitalObject
            }
    }