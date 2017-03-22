#!/bin/bash
# Usage: massfio <fio_config.ini> <nodes>

if ! [ -f "$1" ]; then 
    echo "massfio: job file $1 is not exist!"
    echo "Usage: massfio <fio_config.ini> <nodes>"
    exit 1
fi

trap 'kill $(jobs -p); echo;' EXIT

for client in "${@:2}"; do
    mkdir -p "results/$client"
    rm -f results/errors.log
    while [ $? == 0 ]; do
        fio --alloc-size=kb --output "results/$client/$(date +"%m-%d-%Y-%T").txt" --client "$client" "$1" > /dev/null 2>> results/errors.log
    done &
done

while true; do
    printf "\033c"
    echo "----------------"
    echo "| running jobs |"
    echo "----------------"
    ps T | grep fio | grep -v 'massfio\|grep'
    echo
    echo "---------------"
    echo "| last errors |"
    echo "---------------"
    tail results/errors.log
    sleep 2
done
