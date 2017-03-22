#!/bin/bash
# Usage: massfio <fio_config.ini> <nodes>

if ! [ -f "$1" ]; then 
    echo "massfio: job file $1 is not exist!"
    echo "Usage: massfio <fio_config.ini> <nodes>"
    exit 1
fi

trap 'kill $(jobs -p); echo;' EXIT
rm -f results/errors.log

for client in "${@:2}"; do
    mkdir -p "results/$client"
    while [ $? == 0 ]; do
        fio --alloc-size=kb --output "results/$client/$(date +"%m-%d-%Y-%T").txt" --client "$client" "$1" > /dev/null 2>> results/errors.log
    done &
done

while true; do
    printf "\033c"
    echo "---------"
    echo "| Total |"
    echo "---------"
    echo
    echo "Jobs: $(ps T | grep fio | grep -v 'massfio\|grep' | wc -l)"
    echo "Errors: " $(cat results/errors.log | grep -v "Connection refused" | wc -l)
    echo
    echo "-------------"
    echo "| last jobs |"
    echo "-------------"
    echo
    ps T | grep fio | grep -v 'massfio\|grep' | tail -n 10
    echo
    echo "---------------"
    echo "| last errors |"
    echo "---------------"
    echo
    tail -n 10 results/errors.log | grep -v "Connection refused"
    sleep 2
done
