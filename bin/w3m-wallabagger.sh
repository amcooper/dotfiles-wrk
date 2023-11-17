#!/bin/bash

set -euo pipefail
token=$(curl --silent -X POST --data grant_type=password --data client_id=3_3kfqif569iqsk8s88koccsk8kkg8oc0o4k8kckoo8ss84cgw0k --data client_secret=4s5ioftf8juocc0woskscogogwgw0wwwsg4cccoscwoc0c88cc --data username=adam --data password="$(secret-tool lookup service wallabag)" 'https://wallabag.theadamcooper.com/oauth/v2/token' | jshon -e access_token | sed 's/"//g')
if [[ -n $token ]]; then
  curl --silent -X POST --header "Authorization: Bearer ${token}" --data url="$1" 'https://wallabag.theadamcooper.com/api/entries.json' &> /dev/null
else
  echo "$(date +"%Y-%m-%d %H:%M") Invalid token" >> /home/adam/.config/local/share/w3m/w3m-wallabagger.log
fi
