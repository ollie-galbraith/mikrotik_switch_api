Function Set-MikrotikSwitchPort
    {
        <#
        .Synopsis
        Allows for changes to be made to a switch port via the Mikrotik SwitchOS API
        .Example
        Set-MikrotikSwitchPort -PortNumber 4 -PortName "NewPortName" -Enabled $true -Credential (Get-Credential) -Url http://<switch_address>
        #>
        
        param(
        [Parameter(Mandatory=$true)]
        [Int]$PortNumber,
        [Parameter(Mandatory=$false)]
        [String]$PortName,
        [Parameter(Mandatory=$false)]
        [Boolean]$Enabled = $true,
        [Parameter(Mandatory=$false)]
        [Boolean]$AutoNeg = $true,
        [Parameter(Mandatory=$true)]
        [PSCredential]$Credential,
        [Parameter(Mandatory=$false)]
        [URI]$URL,
        [Parameter(Mandatory=$false)]
        [Switch]$Force
        )

        $HardConfirm = $false
        $NewConfig = ''
        #Retrieves the current config for the switch
        $MikrotikConfig = Invoke-MikrotikRestMethod -Method Get -URI $URL -Query link.b -Credential $Credential

        #Retrieves the current links
        $CurrentLinks = Get-MikrotikLinks -Credential $Credential -URL $URL

        $PortNameArray = $CurrentLinks | Select-Object -ExpandProperty PortName
        $PortEnabled = $CurrentLinks | Select-Object -ExpandProperty Enabled
        $PortAutoNeg = $CurrentLinks | Select-Object -ExpandProperty AutoNeg

        If($PortName -ne '')
            {
                $NewPortName = $PortName

                If($PortNameArray[$PortNumber - 1] -ne $NewPortName)
                    {
                        #Sets a new port name if the selected port (via -PortNumber) doesnt match the specified port name (-PortName)
                        [string]$NewHexPortNameString = (ConvertFrom-StringToHex -String $NewPortName).ToLower()
                        $MikrotikConfig.nm[$PortNumber - 1] = $NewHexPortNameString

                        $HardConfirm = $true
                    }
            }

        If($PortEnabled[$PortNumber - 1] -ne $Enabled)
            {
                $NewEnabledArray = $PortEnabled
                $NewEnabledArray[$PortNumber - 1] = $Enabled

                #Sets the port enabled state to -Enabled
                $NewEnabledHex = ConvertFrom-ArrayToHex -Array $NewEnabledArray
                $MikrotikConfig.en = $NewEnabledHex

                If($Enabled -eq $false)
                    {
                        $HardConfirm = $true
                    }
            }

        If($PortAutoNeg[$PortNumber - 1] -ne $AutoNeg)
            {
                $NewAutoNegArray = $PortAutoNeg
                $NewAutoNegArray[$PortNumber - 1] = $AutoNeg

                #Sets the port auto-negotiation state to -AutoNeg
                $NewAutoNegHex = ConvertFrom-ArrayToHex -Array $NewAutoNegArray
                $MikrotikConfig.an = $NewAutoNegHex

                If($AutoNeg -eq $false)
                    {
                        $HardConfirm = $true
                    }
            }

        #region Construct the new config to send to the switch
        $NameCount = 0
        $SpeedCount = 0

        $NewConfig = "{en:$($MikrotikConfig.en),nm:["
        ForEach($PortNameHex in $MikrotikConfig.nm)
            {
                If($NameCount -lt ($MikrotikConfig.nm.count - 1))
                    {
                        $NewConfig += "'$PortNameHex',"
                        $NameCount += 1
                    }
                Else
                    {
                        $NewConfig += "'$PortNameHex'"
                    }
            }
        $NewConfig += "],an:$($MikrotikConfig.an),spdc:["
        ForEach($SpeedConfig in $MikrotikConfig.spdc)
            {
                If($SpeedCount -lt ($MikrotikConfig.spdc.count - 1))
                    {
                        $NewConfig += "'$SpeedConfig',"
                        $SpeedCount += 1
                    }
                Else
                    {
                        $NewConfig += "'$SpeedConfig'"
                    }
            }
        $NewConfig += "],dpxc:$($MikrotikConfig.dpxc),fctc:$($MikrotikConfig.fctc),fctr:$($MikrotikConfig.fctr)}"
        #endregion
        
        <#
            Added this here as there is a chance that if the incorrect information is sent to the switch, it can corrupt the config and the switch has to be hard reset.
            From a fair bit of testing, most of the kinks have been ironed out, but rather safe than sorry
        #>
        If(($HardConfirm -eq $true) -and ($Force -ne $true))
            {
                $ConsoleWidth = $Host.UI.RawUI.BufferSize.Width
                $Exclaimation = '!' * $ConsoleWidth
                Write-Host "`n`rConfig that is going to be sent is" -ForegroundColor Yellow
                Write-Host $Exclaimation -ForegroundColor Yellow
                Write-Host "$NewConfig`n`r" -ForegroundColor White
                Write-Host "$Exclaimation`n`r" -ForegroundColor Yellow

                $HardConfirmContinue = Read-Host -Prompt 'Send New Config? Y/N'

                If($HardConfirmContinue -ne 'Y')
                    {
                        Write-Host "Breaking Out..."
                        Break
                    }
                ElseIf($HardConfirmContinue -eq 'Y')
                    {
                        Invoke-MikrotikRestMethod -Method Post -URI $URL -Credential $Credential -Query link.b -Body $NewConfig -NoConversion
                    }
            }
        Else
            {
                Invoke-MikrotikRestMethod -Method Post -URI $URL -Credential $Credential -Query link.b -Body $NewConfig -NoConversion
            }
    }