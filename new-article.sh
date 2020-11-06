#!/bin/bash -x

echo $1
arg1="$1"
charcnt=${#arg1}
echo $charcnt
# 2020-09-24- 11characters
# 50-11=39
if [ $charcnt -lt 39 ]; then
    echo "doit"
    npx zenn new:article --slug `date +%Y-%m-%d`-$1
else
    echo "Too long slug. Be more shorten"
fi
#npx zenn new:article --slug `date +%Y-%m-%d`-
