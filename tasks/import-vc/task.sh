#!/bin/bash

set -eu

export OVA_ISO_PATH='./vc-ova'

file_path=$(find $OVA_ISO_PATH/ -name "*.iso")

echo "$file_path"

mount -o loop "$file_path" /tmp

python vc-ci-pipeline/vc-json-import.py

/tmp/vcsa-cli-installer/lin64/./vcsa-deploy install --verbose --accept-eula --acknowledge-ceip --no-ssl-certificate-verification --skip-ovftool-verification vc-ci-pipeline/vc.json