#!/bin/bash

# joplin-rename.sh
#
# This script slugifies joplin entities (notes and todos)
# (Work in progress)

set -euo pipefail

set -x

joplin use test-notebook

while IFS= read -r -d '' item ; do
  echo "$item"

done < <(joplin ls)

echo "[joplin-rename] All done!"
