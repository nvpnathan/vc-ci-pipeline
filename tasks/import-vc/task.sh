#!/bin/bash

set -eu

export OVA_ISO_PATH='./vc-ova'

file_path=$(find $OVA_ISO_PATH/ -name "*.ova")

echo "$file_path"

if echo $GOVC_INSECURE == "1"
  then echo "Insecure vCenter Cert"
else
  export GOVC_TLS_CA_CERTS=/tmp/vcenter-ca.pem
  echo "$GOVC_CA_CERT" > "$GOVC_TLS_CA_CERTS"
fi

govc import.spec "$file_path" | python -m json.tool > vc-import.json

cat > filters <<'EOF'
.Deployment = $vmSize |
.Name = $vmName |
.DiskProvisioning = $diskType |
.NetworkMapping[].Network = $network |
.PowerOn = $powerOn |
.IPAllocationPolicy = $ipallocation |
(.PropertyMapping[] | select(.Key == "guestinfo.cis.appliance.net.addr.family")).Value = ipv4 |
(.PropertyMapping[] | select(.Key == "guestinfo.cis.appliance.net.mode")).Value = $netmode |
(.PropertyMapping[] | select(.Key == "guestinfo.cis.appliance.net.addr")).Value = $ip0 |
(.PropertyMapping[] | select(.Key == "guestinfo.cis.appliance.net.prefix")).Value = $netmask0 |
(.PropertyMapping[] | select(.Key == "guestinfo.cis.appliance.net.gateway")).Value = $gateway |
(.PropertyMapping[] | select(.Key == "guestinfo.cis.appliance.net.dns.servers")).Value = $dns |
(.PropertyMapping[] | select(.Key == "guestinfo.cis.appliance.net.pnid")).Value = $netid |
(.PropertyMapping[] | select(.Key == "guestinfo.cis.vmdir.password")).Value = $adminPass |
(.PropertyMapping[] | select(.Key == "guestinfo.cis.appliance.root.passwd")).Value = $rootPass |
(.PropertyMapping[] | select(.Key == "vami.domain.VMware-vCenter-Server-Appliance")).Value = $fqdn |
(.PropertyMapping[] | select(.Key == "vami.searchpath.VMware-vCenter-Server-Appliance")).Value = $dnsSearch
EOF

jq \
  --arg vmSize "$VC_DEPLOYMENT_SIZE" \
  --arg ipallocation "$VC_IP_POLICY" \
  --arg ip0 "$VC_IP" \
  --arg netmask0 "$VC_NETMASK" \
  --arg gateway "$VC_GATEWAY" \
  --arg dns "$VC_DNS_SERVER" \
  --arg dnsSearch "$VC_SEARCH_PATH" \
  --arg dnsDomain "$VC_DOMAIN_NAME" \
  --arg network "$VC_PORTGROUP" \
  --arg vmName "$VC_NAME" \
  --arg diskType "$VC_DISK_PROVISION" \
  --argjson powerOn "$VC_POWER_ON" \
  --from-file filters \
  vc-import.json > options.json

cat options.json

if [ -z "$VC_VM_FOLDER" ]; then
  govc import.ova -options=options.json "$file_path"
else
  if [ "$(govc folder.info "$VC_VM_FOLDER" 2>&1 | grep "$VC_VM_FOLDER" | awk '{print $2}')" != "$VC_VM_FOLDER" ]; then
    govc folder.create "$VC_VM_FOLDER"
  fi
  govc import.ova -folder="$VC_VM_FOLDER" -options=options.json "$file_path"
fi