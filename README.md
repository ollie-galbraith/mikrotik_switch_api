# Mikrotik SwitchOS API

For a project that I'm working on I needed to have access to programatically and automatically update my SwitchOS config on the fly. After a little bit of digging it turns out that the backend of SwitchOS uses a fairly basic (but non-human readable) API (with some accompanying JavaScript). 

After lots of clicking buttons, changing text, and playing around with Firefox Debug panel, I have reverse engineered the API from hex and binary to integers and strings. At least I reverse engineered the main pages haha. 

This is a repo containing a Powershell Module (and in the future some Python code and Ansible Collections) to make the correct calls to the API. 
