#!/bin/bash

: '
# Script usage
bash scripts/host_usage.sh psql_host psql_port db_name psql_user psql_password

# Example
bash scripts/host_usage.sh localhost 5432 host_agent postgres password
'
#exit if insufficient args
if [[ $# -ne 5 ]]; then
    printf "Insufficient arguments!\nScript usage\n./scripts/host_info.sh psql_host psql_port db_name psql_user psql_password\n"
    exit 1
fi

#declare variable for args
psql_host="$1"
psql_port=$2
db_name="$3"
psql_user="$4"
psql_password="$5"

#connect to a psql instance without prompting password (environment variable)
export PGPASSWORD=$psql_password

#reusable variable
vmstat=`vmstat -w`

#CPU and Memory usage data
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
hostname=$(hostname -f)
memory_free=$(echo "`free -m`" | awk 'FNR == 2 {print $4}' | xargs)
cpu_idle=$(echo "$vmstat" | awk 'FNR == 3 {print $15}' | xargs)
cpu_kernel=$(echo "$vmstat" | awk 'FNR == 3 {print $14}' | xargs)
disk_io=$(echo "`vmstat -d`" | awk 'FNR == 3 {print $10}' | xargs)
disk_available=$(echo "`df -BM ~`" | awk 'FNR == 2 {print $4}' | tr --delete M | xargs)

#INSERT statement
insert_stmt="INSERT INTO PUBLIC.host_usage VALUES ('$timestamp', (SELECT id FROM PUBLIC.host_info WHERE PUBLIC.host_info.hostname = '$hostname'), $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available);"

#execute statement
psql -h $psql_host -p $psql_port -U $psql_user -d $db_name -c "$insert_stmt"

exit $?
