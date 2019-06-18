#!/bin/bash

set -o errexit
set -o pipefail
# set -o nounset
# set -o xtrace

get_var() {
  local name="$1"

  curl -s -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/attributes/${name}"
}

add_ssh_key () {
    echo "$(get_var "chefNodePublicKey")" >> /home/ubuntu/.ssh/authorized_keys
    echo "AllowUsers ubuntu" >> /etc/ssh/sshd_config
    echo "AuthorizedKeysFile      %h/.ssh/authorized_keys" >> /etc/ssh/sshd_config
}

add_ssh_key
