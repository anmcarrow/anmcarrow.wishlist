#!/bin/bash

while IFS= read -r line; do

    if [[ "${line}" =~ ^-[[:space:]]http[s]?:\/\/.* ]]; then

        # shellcheck disable=SC2001
        url="$(echo "${BASH_REMATCH[0]}" | sed 's/^- //g')"
 
        status=$(curl -o /dev/null -s -w "%{http_code}\n" "$url")
        if [[ $status -ne 200 && $status -ne 301 && $status -ne 302 ]]; then
            line=${line//${url}/~~${url}~~}
        export CHANGED=1
        fi
    fi
    echo "$line"
done < README.md > README_temp.md

mv README_temp.md README.md

if [ "${CHANGED}" ]; then
    echo "Changes detected. Committing..."
    git add README.md
    git commit -m "Cleaned up 404s"
    git push origin master
fi