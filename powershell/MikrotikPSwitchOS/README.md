
# PowerShell

This is where this project started. I knew that eventually this would have to run with something like Python, however I'm still fairly new to Python, so I thought I would proof of concept everything in Powershell first. 



## Installation

To install, simply download the module files and install to your choice of paths in ```$env:PSModulePath```

```powershell
  Copy-Item <path-to-module> -Destination <PSModulePath>
  Import-Module MikrotikPSwitchOS
```
    
## Usage/Examples

#### Get-MikrotikLinks
```powershell
PS C:\> $Credential = Get-Credential
PS C:\> $URL = 'http://mikrotik-switch.url.com'

PS C:\> Get-MikrotikLinks -Credential $Credential -URL $URL 

Enabled PortNumber PortType PortName      LinkSpeed LinkActive AutoNeg FullDuplex
------- ---------- -------- --------      --------- ---------- ------- ----------
   True          1 rj45     Router                1       True    True       True
   True          2 rj45     Port2                 1       True    True       True
   True          3 rj45     Port3                 1       True    True       True
   True          4 rj45     Port4                 1       True    True       True
   True          5 rj45     Port5                 0      False    True      False
   True          6 rj45     Port6                 0      False    True      False
   True          7 rj45     Port7                 0      False    True      False
...
```

#### Get-MikrotikSFP
```powershell
PS C:\> $Credential = Get-Credential
PS C:\> $URL = 'http://mikrotik-switch.url.com'

PS C:\> Get-MikrotikSFP -Credential $Credential -URL $URL

PortNumber PortName  Vendor           PartNumber       Serial           Type      Temp Voltage
---------- --------  ------           ----------       ------           ----      ---- -------
        25 SFP1      MikroTik         S+RJ10           HCR01V1VFSK      1m copper   83   3.272
        26 SFP2      Ubiquiti Inc.    UC-DAC-SFP+      AH22018007220    1m copper    0       0
        27 SFP3                                                                      0       0
        28 SFP4                                                                      0       0
```

#### Get-MikrotikVLANs
```powershell
PS C:\> $Credential = Get-Credential
PS C:\> $URL = 'http://mikrotik-switch.url.com'

PS C:\> Get-MikrotikVLANs -Credential $Credential -URL $URL

PortNumber PortName      VLANMode VLANReceive VLANID ForceVLANID
---------- --------      -------- ----------- ------ -----------
         1 Router        Optional Any              1       False
         2 Port2         Optional Any             88       False
         3 Port3         Optional Any             88       False
         4 Port4         Optional Any             88       False
         5 Port5         Optional Any             88       False
         6 Port6         Optional Any             88       False
         7 Port7         Optional Any             88       False
```

#### Set-MikroTikSwitchPort
```powershell
PS C:\> $Credential = Get-Credential
PS C:\> $URL = 'http://mikrotik-switch.url.com'

PS C:\> Get-MikrotikLinks -Credential $Credential -URL $URL 

Enabled PortNumber PortType PortName      LinkSpeed LinkActive AutoNeg FullDuplex
------- ---------- -------- --------      --------- ---------- ------- ----------
   True          1 rj45     Router                1       True    True       True
   True          2 rj45     Port2                 1       True    True       True
   True          3 rj45     Port3                 1       True    True       True
   True          4 rj45     Port4                 1       True    True       True
   True          5 rj45     Port5                 0      False    True      False
   True          6 rj45     Port6                 0      False    True      False
   True          7 rj45     Port7                 0      False    True      False
...

PS C:\> Set-MikrotikSwitchPort -PortNumber 6 -PortName Testing -Enabled $false -Credential $Credential -URL $URL
PS C:\> Get-MikrotikLinks -Credential $Credential -URL $URL 

Enabled PortNumber PortType PortName      LinkSpeed LinkActive AutoNeg FullDuplex
------- ---------- -------- --------      --------- ---------- ------- ----------
   True          1 rj45     Router                1       True    True       True
   True          2 rj45     Port2                 1       True    True       True
   True          3 rj45     Port3                 1       True    True       True
   True          4 rj45     Port4                 1       True    True       True
   True          5 rj45     Port5                 0      False    True      False
  False          6 rj45     Testing               0      False    True      False
   True          7 rj45     Port7                 0      False    True      False
...
```

#### Set-MikroTikVLAN
```powershell
PS C:\> $Credential = Get-Credential
PS C:\> $URL = 'http://mikrotik-switch.url.com'

PS C:\> Get-MikrotikVLANs -Credential $Credential -URL $URL 

PortNumber PortName      VLANMode VLANReceive VLANID ForceVLANID
---------- --------      -------- ----------- ------ -----------
         1 Router        Optional Any              1       False
         2 Port2         Optional Any             88       False
         3 Port3         Optional Any             88       False
         4 Port4         Optional Any             88       False
         5 Port5         Optional Any             88       False
         6 Port6         Optional Any             88       False
         7 Port7         Optional Any             88       False
...

PS C:\> Set-MikrotikVLAN -PortNumber 6 -VLANMode Disabled -VLANReceive 'Only Tagged' -VLANID 99 -Credential $Credential -URL $URL
PS C:\> Get-MikrotikLinks -Credential $Credential -URL $URL 

PortNumber PortName      VLANMode VLANReceive VLANID ForceVLANID
---------- --------      -------- ----------- ------ -----------
         1 Router        Optional Any              1       False
         2 Port2         Optional Any             88       False
         3 Port3         Optional Any             88       False
         4 Port4         Optional Any             88       False
         5 Port5         Optional Any             88       False
         6 Port6         Disabled Only Tagged     99       False
         7 Port7         Optional Any             88       False
...
```
