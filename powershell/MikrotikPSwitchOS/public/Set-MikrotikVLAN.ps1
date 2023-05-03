Function Set-MikrotikVLAN
    {
        <#
        .Synopsis
        Allows for changes to be made to a VLAN configuration via the Mikrotik SwitchOS API
        .Example
        Set-MikrotikVLAN-PortNumber 4 -VLANMode "Enabled" -VLANReceive "Only Untagged" -Credential (Get-Credential) -Url http://<switch_address>
        #>
        
        param(
        [Parameter(Mandatory=$true)]
        [Int]$PortNumber,
        [Parameter(Mandatory=$false)]
        [ValidateSet('Disabled','Optional','Enabled','Strict')]
        [string]$VLANMode,
        [Parameter(Mandatory=$false)]
        [ValidateSet('Any','Only Tagged','Only Untagged')]
        [string]$VLANReceive,
        [Parameter(Mandatory=$false)]
        [Int]$VLANID,
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
        $MikrotikConfig = Invoke-MikrotikRestMethod -Method Get -URI $URL -Query fwd.b -Credential $Credential

        #Retrieves the current VLANs
        $CurrentVLANs = Get-MikrotikVLANs -Credential $Credential -URL $URL

        $VLANModeArray = $CurrentVLANs | Select-Object -ExpandProperty VLANMode
        $VLANReceiveArray = $CurrentVLANs | Select-Object -ExpandProperty VLANReceive
        $DefaultVLANArray = $CurrentVLANs | Select-Object -ExpandProperty VLANID

        If($VLANMode -ne '')
            {
                If($VLANModeArray[$PortNumber - 1] -ne $VLANMode)
                    {
                        #Sets a new VLAN mode if the selected port (via -PortNumber) doesnt match the specified VLAN mode (-VLANMode)
                        $NewVLANMode = Convert-MikrotikVLANMode -String $VLANMode
                        $MikrotikConfig.vlan[$PortNumber - 1] = $NewVLANMode

                        $HardConfirm = $true
                    }
            }
        If($VLANReceive -ne '')
            {
                If($VLANReceiveArray[$PortNumber - 1] -ne $VLANReceive)
                    {
                        #Sets a new VLAN receive mode if the selected port (via -PortNumber) doesnt match the specified VLAN receive mode (-VLANReceive)
                        $NewVLANReceive = Convert-MikrotikVLANReceive -String $VLANReceive
                        $MikrotikConfig.vlni[$PortNumber - 1] = $NewVLANReceive

                        $HardConfirm = $true
                    }
            }
        If($VLANID -ne $null)
            {
                If($DefaultVLANArray[$PortNumber - 1] -ne $VLANID )
                    {
                        #Sets a new VLAN ID if the selected port (via -PortNumber) doesnt match the specified VLAN ID (-VLANID)
                        $NewDefaultVLAN = ConvertFrom-IntToHex -Int $VLANID -PadLength 4
                        $MikrotikConfig.dvid[$PortNumber - 1] = $NewDefaultVLAN

                        $HardConfirm = $true
                    }
            }

        $VLANModeCount = 0
        $VLANReceiveCount = 0
        $VLANIDCount = 0

        #region Construct the new config to send to the switch
        $NewConfig = "{vlan:["
        ForEach($PortVLANMode in $MikrotikConfig.vlan)
            {
                If($VLANModeCount -lt ($MikrotikConfig.vlan.count - 1))
                    {
                        $NewConfig += "$PortVLANMode,"
                        $VLANModeCount += 1 
                    }
                Else
                    {
                        $NewConfig += "$PortVLANMode"
                    }
            }
        $NewConfig += "],vlni:["
        ForEach($PortVLANReceive in $MikrotikConfig.vlni)
            {
                If($VLANReceiveCount -lt ($MikrotikConfig.vlni.count - 1))
                    {
                        $NewConfig += "$PortVLANReceive,"
                        $VLANReceiveCount += 1
                    }
                Else
                    {
                        $NewConfig += "$PortVLANReceive"
                    }
                    
            }
        $NewConfig += "],dvid:["
        ForEach($PortVLANDefault in $MikrotikConfig.dvid)
            {
                If($VLANIDCount -lt ($MikrotikConfig.dvid.count - 1))
                    {
                        $NewConfig += "$PortVLANDefault,"
                        $VLANIDCount += 1
                    }
                Else
                    {
                        $NewConfig += "$PortVLANDefault"
                    }
                
            }
        $NewConfig += "]}"
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
                        Invoke-MikrotikRestMethod -Method Post -URI $URL -Credential $Credential -Query fwd.b -Body $NewConfig -NoConversion
                    }
            }
        Else
            {
                Invoke-MikrotikRestMethod -Method Post -URI $URL -Credential $Credential -Query fwd.b -Body $NewConfig -NoConversion
            }
    }