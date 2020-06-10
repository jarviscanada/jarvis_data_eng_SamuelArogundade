#!/bin/bash

: '
Script usage 
./scripts/host_info.sh psql_host psql_port db_name psql_user psql_password

Example
./scripts/host_info.sh "localhost" 5432 "host_agent" "postgres" "mypassword"
'

if [[ $# -ne 5 ]]; then
    printf "Insufficient arguments!\nScript usage\n./scripts/host_info.sh psql_host psql_port db_name psql_user psql_password\n"
    exit 1
fi

psql_host="$1"
psql_port=$2
db_name="$3"
psql_user="$4"
psql_password="$5"

#set password for user
export PGPASSWORD=$psql_password

#store the values of cpu details to be extracted from
lscpu_out=`lscpu`

#hardware info
hostname=`hostname -f`
cpu_number=$(echo "$lscpu_out"  | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out"  | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out"  | egrep "^Model:" | awk '{print $2}' | xargs)
cpu_mhz=$(echo "$lscpu_out"  | egrep "^CPU MHz:" | awk '{print $3}' | xargs)
l2_cache=$(echo "$lscpu_out" | egrep "^L2 cache:" | awk '{print $3}' | xargs  | tr --delete K)
total_mem=$(echo `cat /proc/meminfo` | egrep "^MemTotal:" | awk '{print $2}' | xargs)
timestamp=`date '+%Y-%m-%d %H:%M:%S'`

#insert statement to be executed
insert_stmt="INSERT INTO PUBLIC.host_info VALUES ($hostname, $cpu_number, $cpu_architecture, $cpu_model, $cpu_mhz, $l2_cache, $total_mem, $timestamp);"

#connect and execute statement
psql -h $psql_host -p $psql_port -U $psql_user -d $db_name -c "$insert_stmt"

exit $?
