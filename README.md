# Mikrotik SwitchOS API

### Built With
![PowerShell][powershell-badge]
![Python][python-badge]
![Ansible][ansible-badge]

For a project that I'm working on I needed to have access to programatically and automatically update my SwitchOS config on the fly. After a little bit of digging it turns out that the backend of SwitchOS uses a fairly basic (but non-human readable) API (with some accompanying JavaScript). 

After lots of clicking buttons, changing text, and playing around with Firefox Debug panel, I have reverse engineered the API from hex and binary to integers and strings. At least I reverse engineered the main pages haha. 

This is a repo containing a Powershell Module and basic Python/Ansible code to make the correct calls to the API. 

## Usage 

#### Powershell 
Refer to the [Powershell README.md](/powershell/MikrotikPSwitchOS/README.md)

#### Python 
The Python code is a simple port of the Powershell, and has the same structure/function. I am still learning to get around Python, so please forgive any "non-pythonic" code that there might be, or the lack of a proper package.

#### Ansible
Refer to the [Ansible README.md](/ansible/README.md)

## FAQ

#### How does the API work

While I dont know the ins and outs of the inner workings of the API, there is enough information from the JSON-like responses depending on the request that its easy enough to reverse engineer. 

It is mostly hex numbers and bitmasks, which need to be converted to be able to read them as a human. Thanks to this [forum post](https://forum.mikrotik.com/viewtopic.php?t=172802) for the basic information to get going

## To Note
This is a side project for me, and I have only manaaged to test the code on three switch models
 - [CRS328-24P-4S+RM](https://mikrotik.com/product/crs328_24p_4s_rm)
 - [CRS309-1G-8S+IN](https://mikrotik.com/product/crs309_1g_8s_in)
 - [CSS326-24G-2S+RM](https://mikrotik.com/product/CSS326-24G-2SplusRM)

There are bound to be some bugs with the code.
There is a possiblity that if an incorrect config is sent to the switch, it can corrupt and only be saved with a hard reboot. So please practice backups. 

[ansible-badge]: https://shields.io/badge/ansible-20232A?style=for-the-badge&logo=ansible&logoColor=ff5750
[python-badge]: https://shields.io/badge/python-20232A?style=for-the-badge&logo=python&logoColor=61DAFB
[powershell-badge]: https://shields.io/badge/powershell-20232A?style=for-the-badge&logo=powershell&logoColor=61DAFB
[powershell-url]: https://learn.microsoft.com/en-us/powershell/
