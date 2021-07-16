#!/bin/bash

set -euxo pipefail

for F in *.png; do
	N=$(echo "$F" | sed -E 's|.png$||')
	echo "${N}"
	convert -crop 96x192 "$F" "../${N}_%02d.png"
done
