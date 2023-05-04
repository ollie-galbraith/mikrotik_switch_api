# Mikrotik SwitchOS API

### Built With
![PowerShell][powershell-badge]

For a project that I'm working on I needed to have access to programatically and automatically update my SwitchOS config on the fly. After a little bit of digging it turns out that the backend of SwitchOS uses a fairly basic (but non-human readable) API (with some accompanying JavaScript). 

After lots of clicking buttons, changing text, and playing around with Firefox Debug panel, I have reverse engineered the API from hex and binary to integers and strings. At least I reverse engineered the main pages haha. 

This is a repo containing a Powershell Module and basic Python/Ansible code to make the correct calls to the API. 

### To Note
This is a side project for me, and I have only manaaged to test the code on three switch models
 - [CRS328-24P-4S+RM](https://mikrotik.com/product/crs328_24p_4s_rm)
 - [CRS309-1G-8S+IN](https://mikrotik.com/product/crs309_1g_8s_in)
 - [CSS326-24G-2S+RM](https://mikrotik.com/product/CSS326-24G-2SplusRM)

There are bound to be some bugs with the code.
There is a possiblity that if an incorrect config is sent to the switch, it can corrupt and only be saved with a hard reboot. So please practice backups. 

[python-badge]: https://shields.io/badge/python-20232A?style=for-the-badge&logo=python&logoColor=61DAFB
[powershell-badge]: https://shields.io/badge/powershell-20232A?style=for-the-badge&logo=powershell&logoColor=61DAFB
[powershell-url]: https://learn.microsoft.com/en-us/powershell/
