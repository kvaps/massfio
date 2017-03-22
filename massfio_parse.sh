#!/bin/bash
# Usage: massfio_parse <reults_dir>

avg() {
    awk '
  BEGIN {
    c = 0;
    sum = 0;
  }
  $1 ~ /^[0-9]*(\.[0-9]*)?$/ {
    a[c++] = $1;
    sum += $1;
  }
  END {
    ave = sum / c;
    if( (c % 2) == 1 ) {
      median = a[ int(c/2) ];
    } else {
      median = ( a[c/2] + a[c/2-1] ) / 2;
    }
    OFS="\t";
    print ave;
  }
'
}

convert_bw(){
    while read data; do
        echo $data | awk '/[0-9]$/{print $1;next};/[kK]$/{printf "%u\n", $1;next};/[gG]$/{printf "%u\n", $1*(1024*1024);next};/[mM]$/{printf "%u\n", $1*1024;next}'
    done
}

convert_iops(){
    while read data; do
        if [[ $data  == *k* ]]; then
            echo "$(echo $data | sed 's/k//g') * 1000" | bc
        else
            echo $data
        fi
    done
}

convert_lat(){
    while read data; do
        if [[ $data  == *(usec)* ]]; then
            echo $data | grep -oP '(?<=avg=)[0-9]*' 
        elif [[ $data  == *(msec)* ]]; then
            echo "$(echo $data | grep -oP '(?<=avg=)[0-9]*') * 1000" | bc
        fi
    done
}

echo
echo "---------"
echo "| Write |"
echo "---------"
echo

echo -n "iodepth: "
echo -n $(grep -r writetest $1 | grep -oP '(?<=iodepth=)[0-9]*' | avg)
echo

echo -n "latency: "
echo -n $(grep -r writetest -A3 $1 | grep clat | convert_lat | avg)
echo " (usec)"


echo -n "bandwidth: "
echo -n $(grep -r writetest $1 -A1 | grep -oP '(?<=BW=)[0-9.kKmMgG]*' | convert_bw | avg)
echo " KiB/s"

echo -n "IOPS: "
echo $(grep -r writetest $1 -A1 | grep -oP '(?<=IOPS=)[0-9.k]*' | convert_iops | avg)
echo

echo
echo "--------"
echo "| Read |"
echo "--------"
echo

echo -n "iodepth: "
echo -n $(grep -r readtest $1 | grep -oP '(?<=iodepth=)[0-9]*' | avg)
echo

echo -n "latency: "
echo -n $(grep -r readtest -A3 $1 | grep clat | convert_lat | avg)
echo " (usec)"

echo -n "bandwidth: "
echo -n $(grep -r readtest $1 -A1 | grep -oP '(?<=BW=)[0-9.kKmMgG]*' | convert_bw | avg)
echo " KiB/s"

echo -n "IOPS: "
echo -n $(grep -r readtest $1 -A1 | grep -oP '(?<=IOPS=)[0-9.k]*' | convert_iops | avg)
echo

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
