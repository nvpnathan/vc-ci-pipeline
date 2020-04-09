import json
import os
print(os.environ)

with open('/tmp/vcsa-cli-installer/templates/install/embedded_vCSA_on_ESXi.json') as json_file:
    data = json.load(json_file)

data['new_vcsa']['esxi']['hostname'] = os.environ.get('ESXI_HOST')
data['new_vcsa']['esxi']['username'] = os.environ.get('ESXI_USR')
data['new_vcsa']['esxi']['password'] = os.environ.get('ESXI_PWD')
data['new_vcsa']['esxi']['datastore'] = os.environ.get('ESXI_DATASTORE')
data['new_vcsa']['esxi']['deployment_network'] = os.environ.get('VC_PORTGROUP')
data['new_vcsa']['appliance']['thin_disk_mode'] = bool(os.environ.get('VC_THIN_PROVISION'))
data['new_vcsa']['appliance']['deployment_option'] = os.environ.get('VC_DEPLOYMENT_SIZE')
data['new_vcsa']['appliance']['name'] = os.environ.get('VC_NAME')
data['new_vcsa']['network']['mode'] = os.environ.get('VC_NET_MODE')
data['new_vcsa']['network']['ip'] = os.environ.get('VC_IP')
data['new_vcsa']['network']['dns_servers'] = os.environ.get('[VC_DNS_SERVER]')
data['new_vcsa']['network']['prefix'] = os.environ.get('VC_NETMASK')
data['new_vcsa']['network']['gateway'] = os.environ.get('VC_GATEWAY')
data['new_vcsa']['network']['system_name'] = os.environ.get('VC_SYSTEM_NAME')
data['new_vcsa']['os']['password'] = os.environ.get('VC_ROOT_PWD')
data['new_vcsa']['os']['ntp_servers'] = os.environ.get('VC_NTP_SERVER')
data['new_vcsa']['os']['ssh_enable'] = bool(os.environ.get('VC_SSH_ENABLED'))
data['new_vcsa']['sso']['password'] = os.environ.get('VC_SSO_PWD')
data['new_vcsa']['sso']['domain_name'] = os.environ.get('VC_SSO_DOMAIN')
data['ceip']['settings']['ceip_enabled'] =  bool(os.environ.get('CEIP_ENABLED'))

print(data)

with open ('vc.json', 'w') as fp:
    json.dump(data, fp, indent=4)