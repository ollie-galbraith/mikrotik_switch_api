# Ansible

I wrote this small wrapper for Ansible so I could idempotentaly make changes to a Mikrotik Switch via Ansible 

## Parameters

| Parameter | Comments |
| :-------- | :------- |
| `auto_neg`<br>boolen | Enables or disables Auto-Negotiation for the switch port<br>`Choices:`<br>`false`<br>`true` |
| `command_type`<br>string | Tells Ansible whether to run a "get" command or a "set" command<br>`Choices:`<br>`get (default)`<br>`set` |
| `enabled`<br>boolen | Enables or disables the switch port<br>`Choices:`<br>`false`<br>`true` |
| `output_only`<br>string | Returns the specified parameter<br>`Choices:`<br>`port_name`<br>`enabled`<br>`auto_neg` |
| `port_name`<br>string | Name of the port |
| `port_number`<br>integer | The port number to run the API call against |
| `switch_password`<br>string | Password to give access to the switch |
| `switch_url`<br>string | URL that the switch is accessed from |
| `switch_username`<br>string | Username to give access to the switch |
