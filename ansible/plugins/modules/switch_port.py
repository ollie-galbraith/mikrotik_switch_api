#!/usr/bin/python

from ansible.module_utils.basic import * 
import re
import json
import requests
from requests.auth import HTTPDigestAuth

def send_Mikrotik_Rest_Method(url, method, query, username, password, body=None):
    headers = {
        "Accept": "*/*",
        "Accept-Language": "en-US,en;q=0.5",
        "Accept-Encoding": "gzip, deflate",
        "Content-Type": "text/plain",
        "Origin": f"{url}",
        "Referer":  f"{url}/index.html"
    }

    url = f"{url}/{query}"

    request_params = dict(
        method = method,
        url = url, 
        headers = headers,
        auth = HTTPDigestAuth(username=username, password=password)
    )

    if body != None:
        request_params['data'] = body

    response = requests.request(**request_params)
    return response.text

def convert_Mikrotik_Json(input_object):
    json_dump = input_object

    word_regex = r"(\w+)"
    single_quote_regex = r"(\')"
    double_double_quote_regex = r'\"{2}(\w+)\"{2}'

    json_dump = re.sub(word_regex, r'"\1"', json_dump)
    json_dump = re.sub(single_quote_regex, r'"', json_dump)
    json_dump = re.sub(double_double_quote_regex, r'"\1"', json_dump)
    json_dump = re.sub('],}','}]', json_dump)

    json_output = json.loads(json_dump)

    return json_output

def convert_Mikrotik_Array_Hex(array, padding=8):
    binary_string = str('')
    array.reverse()
    for item in array:
        if item == True:
            bin = '1'
        elif item == False:
            bin = '0'
        binary_string += bin
    
    padding = padding + 2
    hex_output = f"{int(binary_string, 2):#0{padding}x}"
    return hex_output

def convert_Mikrotik_Link_Speed(hex_string):
    SwOS_link_speeds = {
        '0x01': 0.1,
        '0x02': 1.0,
        '0x07': 0.0,
        '0x04': 0.0,
        '0x03': 10.0
    }

    for speeds in SwOS_link_speeds:
        if speeds == hex_string:
            return SwOS_link_speeds[speeds]

def convert_Mikrotik_Hex_Array(hex_string, pad_length):
    output = []
    binary = f'{int(hex_string, 16):0>{pad_length}b}'
    for element in binary:
        if element == '1':
            output.append(True)
        else:
            output.append(False)
    output.reverse()
    return output

def get_Mikrotik_Switch_Port(url, username, password, port_number=None, port_name=None, output_only=None):
    query = 'link.b'
    method = 'GET'
    response = send_Mikrotik_Rest_Method(url=url, query=query, method=method, username=username, password=password)
    links = convert_Mikrotik_Json(input_object=response)
    
    total_ports = int(links['prt'], 16)
    port_instance = 0
    output = []

    enabled_ports = convert_Mikrotik_Hex_Array(hex_string=links['en'], pad_length=total_ports)
    link_active = convert_Mikrotik_Hex_Array(hex_string=links['lnk'] , pad_length=total_ports)
    auto_neg_ports = convert_Mikrotik_Hex_Array(hex_string=links['an'], pad_length=total_ports)
    duplex_ports = convert_Mikrotik_Hex_Array(hex_string=links['dpx'], pad_length=total_ports)

    while port_instance < total_ports:
        object = {
            'enabled': enabled_ports[port_instance],
            'port_number': port_instance + 1,
            'port_name': bytes.fromhex(links['nm'][port_instance]).decode('utf-8'),
            'link_speed': convert_Mikrotik_Link_Speed(hex_string=links['spd'][port_instance]),
            'link_active': link_active[port_instance],
            'auto_neg': auto_neg_ports[port_instance],
            'full_duplex': duplex_ports[port_instance],
        }
        port_instance += 1
        output.append(object)

    output_options = (
        'port_name',
        'enabled',
        'auto_neg'
    )

    result = []
    if output_only in output_options:
        for item in output:
            result.append(item[output_only])
    else:  
        if port_number != None:
            result = output[port_number - 1]
        elif port_name != None:
            for ports in output:
                if ports['port_name'] == port_name:
                    result.append(ports)
        else:
            result = output

    return result

def set_Mikrotik_Switch_Port(url, username, password, port_number, port_name=None, enabled=True, auto_neg=True):
    query = 'link.b'
    response = send_Mikrotik_Rest_Method(url=url, query=query, method='GET', username=username, password=password)
    mikrotik_config = convert_Mikrotik_Json(input_object=response)

    new_mikrotik_config = ''
    name_count = 1
    speed_count = 1

    get_Mikrotik_Link_params = dict(
        url = url, 
        username = username, 
        password = password
    )

    port_names = get_Mikrotik_Switch_Port(**get_Mikrotik_Link_params, output_only='port_name')
    port_enabled = get_Mikrotik_Switch_Port(**get_Mikrotik_Link_params, output_only='enabled')
    port_auto_neg = get_Mikrotik_Switch_Port(**get_Mikrotik_Link_params, output_only='auto_neg')

    array_port_number = port_number - 1
    #print(mikrotik_config)
    if port_name != None:
        new_port_name = port_name
        if new_port_name not in port_names:
            new_port_name_hex = new_port_name.encode('utf-8').hex()
            mikrotik_config['nm'][array_port_number] = new_port_name_hex

    if port_enabled[array_port_number] != enabled:
        new_port_enabled = list(port_enabled)
        new_port_enabled[array_port_number] = enabled

        new_port_enabled_hex = convert_Mikrotik_Array_Hex(array=new_port_enabled)
        mikrotik_config['en'] = new_port_enabled_hex

    if port_auto_neg[array_port_number] != auto_neg:
        new_port_auto_neg = list(port_auto_neg)
        new_port_auto_neg[array_port_number] = auto_neg

        new_port_auto_neg_hex = convert_Mikrotik_Array_Hex(array=new_port_auto_neg)
        mikrotik_config['an'] = new_port_auto_neg_hex

    new_mikrotik_config += f"{{en:{mikrotik_config['en']},nm:["
    for name_hex in mikrotik_config['nm']:
        if name_count <= (len(mikrotik_config['nm']) - 1):
            new_mikrotik_config += f"'{name_hex}',"
            name_count += 1
        else:
            new_mikrotik_config += f"'{name_hex}'"
    new_mikrotik_config += f"],an:{mikrotik_config['an']},spdc:["
    for speed_hex in mikrotik_config['spdc']:
        if speed_count <= (len(mikrotik_config['spdc']) - 1):
            new_mikrotik_config += f"'{speed_hex}',"
            speed_count += 1
        else:
            new_mikrotik_config += f"'{speed_hex}'"
    new_mikrotik_config += f"],dpxc:{mikrotik_config['dpxc']},fctc:{mikrotik_config['fctc']},fctr:{mikrotik_config['fctr']}}}"

    send_Mikrotik_Rest_Method(url=url, query=query, method='POST', username=username, password=password, body=new_mikrotik_config)

def ports():
    module_args = dict(
        switch_url=dict(type='str', required=True),
        switch_username=dict(type='str', required=True),
        switch_password=dict(type='str', required=True, no_log=True),
        command_type=dict(
            type='str', 
            required=False, 
            choices = ['get','set'],
            default='get'),
        port_name=dict(type='str', required=False),
        port_number=dict(type='int', required=False),
        enabled=dict(type='bool', required=False),
        auto_neg=dict(type='bool', required=False),
        output_only=dict(
            type='str', 
            required=False, 
            choices = ['port_name','enabled','auto_neg'])
    )

    result = dict(
        changed = False,
        original_message = '',
        ports = ''
    )

    module = AnsibleModule(
        argument_spec = module_args,
        supports_check_mode = True
    )

    if module.check_mode:
        module.exit_json(**result)

    get_mikrotik_switch_port_params = dict(
        url = module.params['switch_url'], 
        username = module.params['switch_username'], 
        password = module.params['switch_password']
    )

    set_mikrotik_switch_port_params = dict(get_mikrotik_switch_port_params)

    if module.params['port_number'] is not None and module.params['command_type'] == 'set':
        get_mikrotik_switch_port_params['port_number'] = module.params['port_number']
        original_config = get_Mikrotik_Switch_Port(**get_mikrotik_switch_port_params)

        set_mikrotik_switch_port_params['port_number'] = module.params['port_number']

        if module.params['port_name'] is not None:
            set_mikrotik_switch_port_params['port_name'] = module.params['port_name']
            result['prev_port_name'] = original_config['port_name']

        if module.params['enabled'] is not None:
            set_mikrotik_switch_port_params['enabled'] = module.params['enabled']
            result['prev_port_enabled_state'] = original_config['enabled']

        if module.params['auto_neg'] is not None:
            set_mikrotik_switch_port_params['auto_neg'] = module.params['auto_neg']
            result['prev_port_auto_neg_state'] = original_config['auto_neg']

        set_Mikrotik_Switch_Port(**set_mikrotik_switch_port_params)
        output = get_Mikrotik_Switch_Port(**get_mikrotik_switch_port_params)
        result['changed'] = True


    elif module.params['port_number'] is not None and module.params['command_type'] == 'get':
        get_mikrotik_switch_port_params['port_number'] = module.params['port_number']
        output = get_Mikrotik_Switch_Port(**get_mikrotik_switch_port_params)

    elif module.params['port_name'] is not None:
        get_mikrotik_switch_port_params['port_name'] = module.params['port_name']
        output = get_Mikrotik_Switch_Port(**get_mikrotik_switch_port_params)

    elif module.params['output_only'] is not None:
        get_mikrotik_switch_port_params['output_only'] = module.params['output_only']
        output = get_Mikrotik_Switch_Port(**get_mikrotik_switch_port_params)

    else:
        output = get_Mikrotik_Switch_Port(**get_mikrotik_switch_port_params)

    result['ports'] = output
    module.exit_json(**result)

def main():
    ports()

if __name__ == '__main__':
    main()  