#!/bin/bash
set -euo pipefail

cd "$(dirname $0)/.."
source '../test-helpers.sh'

node_deb_version=$(jq -r '.version' 'package.json')
declare -r node_deb_version
declare -r output="node-deb_${node_deb_version}_all/"

finish() {
  rm -rf "$output" *.deb
}

trap 'finish' EXIT

./node-deb --no-delete-temp \
           --verbose \
           -- node-deb templates/

[ $(find "$output" -name 'node-deb' -type f | wc -l) -lt 1 ] || die "Couldn't find node-deb in output"

[ $(find "$output" -name 'templates' -type d | wc -l) -lt 1 ] || die "Couldn't find templates directory"
[ $(find "$output/" -type f | grep 'templates' | wc -l) -lt 1 ] || die "Couldn't find templates"

dpkg -i "node-deb_${node_deb_version}_all.deb"
node-deb --verbose \
         -- node-deb templates/
apt-get purge -y node-deb
