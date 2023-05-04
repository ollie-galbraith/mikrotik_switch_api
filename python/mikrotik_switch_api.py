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

def get_Mikrotik_Hosts(url, username, password):
    query = '!dhost.b'
    method = 'GET'
    response = send_Mikrotik_Rest_Method(url=url, query=query, method=method, username=username, password=password)
    hosts = convert_Mikrotik_Json(input_object=response)
    links = get_Mikrotik_Links(url=url, username=username, password=password)

    output = []
    for host in hosts:
        mac_address = re.sub(r'(.{2})(?!$)', r'\1:', host['adr'])
        vlan_id = int(host['vid'], 16)
        port_number = int(host['prt'], 16) + 1
        port_name = links[port_number - 1]['port_name']
    
        object = {
            'mac_address':mac_address,
            'vlan_id':vlan_id,
            'port_name':port_name,
            'port_number':port_number
        }
        output.append(object)

    return output

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

def convert_Mikrotik_Vlan_Mode(hex_string=None, string=None):
    vlan_modes = {
        '0x00': 'Disabled',
        '0x01': 'Optional',
        '0x02': 'Enabled',
        '0x03': 'Strict'
    }

    for key, value in vlan_modes.items():
        if hex_string != None and key == hex_string:
            return value
        if string != None and value == string:
            return key

def convert_Mikrotik_Vlan_Receive(hex_string=None, string=None):
    vlan_receive = {
        '0x00': 'Any',
        '0x01': 'Only Tagged',
        '0x02': 'Only Untagged'
    }

    for key, value in vlan_receive.items():
        if hex_string != None and key == hex_string:
            return value
        if string != None and value == string:
            return key

def get_Mikrotik_Links(url, username, password, port_number=None, port_name=None, output_only=None):
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

def get_Mikrotik_Vlan(url, username, password, port_number=None, port_name=None, vlan_id=None, output_only=None):
    query = 'fwd.b'
    method = 'GET'
    response = send_Mikrotik_Rest_Method(url=url, query=query, method=method, username=username, password=password)
    links = get_Mikrotik_Links(url=url, username=username, password=password)
    vlans = convert_Mikrotik_Json(input_object=response)

    total_ports = len(links)
    port_instance = 0
    output = []

    force_vlan = convert_Mikrotik_Hex_Array(hex_string=vlans['fvid'], pad_length=total_ports)

    while port_instance < total_ports:
        object = {
            'port_number': port_instance + 1,
            'port_name': links[port_instance]['port_name'],
            'vlan_mode': convert_Mikrotik_Vlan_Mode(hex_string=vlans['vlan'][port_instance]),
            'vlan_receive': convert_Mikrotik_Vlan_Receive(hex_string=vlans['vlni'][port_instance]),
            'vlan_id': int(vlans['dvid'][port_instance], 16),
            'force_vlan': force_vlan[port_instance],
        }
        port_instance += 1
        output.append(object)
    
    output_options = (
        'vlan_mode',
        'vlan_receive',
        'vlan_id'
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
        elif vlan_id != None:
            for ports in output:
                if ports['vlan_id'] == vlan_id:
                    result.append(ports)
        else:
            result = output

    return result

def get_Mikrotik_Vlan_Config(url, username, password):
    query = 'vlan.b'
    method = 'GET'
    response = send_Mikrotik_Rest_Method(url=url, query=query, method=method, username=username, password=password)
    vlans = convert_Mikrotik_Json(input_object=response)

    vlan_instance = 0
    output = []

    for vlan in vlans:
        object = {
            "vlan_id": int(vlans[vlan_instance]['vid'], 16),
            'port_isolation': int(vlans[vlan_instance]['piso'], 16),
            'learning': int(vlans[vlan_instance]['lrn'], 16),
            'mirror': int(vlans[vlan_instance]['mrr'], 16),
            'igmp_snoop': int(vlans[vlan_instance]['igmp'], 16),
            'members': convert_Mikrotik_Hex_Array(hex_string=vlans[vlan_instance]['mbr'], pad_length=26)
        }
        vlan_instance += 1
        output.append(object)
    
    return output

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

    port_names = get_Mikrotik_Links(**get_Mikrotik_Link_params, output_only='port_name')
    port_enabled = get_Mikrotik_Links(**get_Mikrotik_Link_params, output_only='enabled')
    port_auto_neg = get_Mikrotik_Links(**get_Mikrotik_Link_params, output_only='auto_neg')

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

def set_Mikrotik_Vlan(url, username, password, port_number, vlan_mode=None, vlan_receive=None, vlan_id=None):
    query = 'fwd.b'
    response = send_Mikrotik_Rest_Method(url=url, query=query, method='GET', username=username, password=password)
    mikrotik_config = convert_Mikrotik_Json(input_object=response)

    get_Mikrotik_Vlan_params = dict(
        url = url, 
        username = username, 
        password = password
    )

    array_port_number = port_number - 1

    vlan_mode_count = 1
    vlan_receive_count = 1
    vlan_id_count = 1

    vlan_mode_data = get_Mikrotik_Vlan(**get_Mikrotik_Vlan_params, output_only='vlan_mode')[array_port_number]
    vlan_receive_data = get_Mikrotik_Vlan(**get_Mikrotik_Vlan_params, output_only='vlan_receive')[array_port_number]
    vlan_id_data = get_Mikrotik_Vlan(**get_Mikrotik_Vlan_params, output_only='vlan_id')[array_port_number]

    if vlan_mode != None:
        if vlan_mode_data != vlan_mode:
            new_vlan_mode = convert_Mikrotik_Vlan_Mode(string=vlan_mode)

            mikrotik_config['vlan'][array_port_number] = new_vlan_mode
            print(new_vlan_mode)

    if vlan_receive != None:
        if vlan_receive_data != vlan_receive:
            new_vlan_receive = convert_Mikrotik_Vlan_Receive(string=vlan_receive)
            mikrotik_config['vlni'][array_port_number] = new_vlan_receive
            print(new_vlan_receive)

    if vlan_id != None:
        if vlan_id_data != vlan_id:
            padding = 6
            new_vlan_id = f"{vlan_id:#0{padding}x}"
            mikrotik_config['dvid'][array_port_number] = new_vlan_id
            print(new_vlan_id)

    new_mikrotik_config = '{vlan:['
    for vlan_mode_hex in mikrotik_config['vlan']:
        if vlan_mode_count  <= (len(mikrotik_config['vlan']) - 1):
            new_mikrotik_config += f"{vlan_mode_hex},"
            vlan_mode_count  += 1
        else:
            new_mikrotik_config += f"{vlan_mode_hex}"

    new_mikrotik_config += '],vlni:['
    for vlan_receive_hex in mikrotik_config['vlni']:
        if vlan_receive_count  <= (len(mikrotik_config['vlni']) - 1):
            new_mikrotik_config += f"{vlan_receive_hex},"
            vlan_receive_count  += 1
        else:
            new_mikrotik_config += f"{vlan_receive_hex}"

    new_mikrotik_config += '],dvid:['
    for vlan_id_hex in mikrotik_config['dvid']:
        if vlan_id_count  <= (len(mikrotik_config['dvid']) - 1):
            new_mikrotik_config += f"{vlan_id_hex},"
            vlan_id_count  += 1
        else:
            new_mikrotik_config += f"{vlan_id_hex}"
    
    new_mikrotik_config += ']}'

    send_Mikrotik_Rest_Method(url=url, query=query, method='POST', username=username, password=password, body=new_mikrotik_config)