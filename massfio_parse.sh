#!/bin/bash
# Usage: massfio_parse <reults_dir>

mean() {
    awk ' { a[i++]=$1; } END { print a[int(i/2)]; }'
}
echo
echo "---------"
echo "| Write |"
echo "---------"
echo
echo -n "iodepth: "
grep -r writetest $1 | grep -oP '(?<=iodepth=)[^,]*' | mean
echo -n "latency: "
grep -r writetest -A3 $1 | grep clat | grep -oP '(?<=avg=)[^,]*' | mean
echo -n "bandwidth: "
grep -r writetest $1 -A1 | grep -oP '(?<=BW=)[0-9.]*' | mean
echo -n "IOPS: "
grep -r writetest $1 -A1 | grep -oP '(?<=IOPS=)[0-9.k]*' | mean

echo
echo "--------"
echo "| Read |"
echo "--------"
echo

echo -n "iodepth: "
grep -r readtest $1 | grep -oP '(?<=iodepth=)[^,]*' | mean
echo -n "latency: "
grep -r readtest -A3 $1 | grep clat | grep -oP '(?<=avg=)[^,]*' | mean
echo -n "bandwidth: "
grep -r readtest $1 -A1 | grep -oP '(?<=BW=)[0-9.]*' | mean
echo -n "IOPS: "
grep -r readtest $1 -A1 | grep -oP '(?<=IOPS=)[0-9.k]*' | mean

echo 
echo "---------"
echo "| Total |"
echo "---------"
echo

echo -n "write tests: "
grep -r writetest $1 |  grep "err= 0" | wc -l
echo -n "read tests: "
grep -r readtest $1 |  grep "err= 0" | wc -l
echo
echo -n "success hosts: "
for i in $(grep -rl "err= 0" $1 ); do basename $(dirname $i) ; done | sort -u | wc -l
echo "    ( $(echo $(for i in $(grep -rl "err= 0" $1 ); do basename $(dirname $i) ; done | sort -u)) )"
echo
echo -n "error hosts: "
for i in $(grep -rl "failed" $1 ); do basename $(dirname $i) ; done | sort -u | wc -l
echo "    ( $(echo $(for i in $(grep -rl "failed" $1 ); do basename $(dirname $i) ; done | sort -u)) )"
echo
