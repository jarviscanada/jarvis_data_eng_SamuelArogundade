# Introduction

    Cluster Monitor Agent is an internal tool that monitors the hardware specifications of each node and monitor node resource usages (e.g. CPU/Memory) in real time. The collected data is stored in a PSQL database. 
    This project explores how to create a monitoring agent by utilizing bash scripts that create a PSQL docker container, create tables and inserts into them data regarding host info and usage. A crontab job is then triggered every minute which collects the average host usage data.
    The data can be used to generate some reports for future resource planning purposes (e.g. add/remove servers).
    
    Linux Cluster Administration (LCA)
    
# Quick Start

    - Start a psql instance using psql_docker.sh
    ./scripts/psql_docker.sh create db_username db_password
    
    - Create tables using ddl.sql
    psql -h localhost -U postgres -d host_agent -f sql/ddl.sql
    
    - Insert hardware specs data into the db using host_info.sh
    ./scripts/host_info.sh psql_host psql_port db_name psql_user psql_password
    
    - Insert hardware usage data into the db using host_usage.sh
    ./scripts/host_info.sh psql_usage psql_port db_name psql_user psql_password
    
    - Crontab setup
    crontab -e 
    
    # Add the line to the open editor to collect the usage data every minute 
    * * * * * bash /`pwd`/host_usage.sh [psql host] [port] host_agent [db_username] [db_password] &> /tmp/host_usage.log

# Architecture Diagram

![Architecture](https://github.com/jarviscanada/jarvis_data_eng_SamuelArogundade/blob/develop/linux_sql/assets/arch.jpg)

# Database Modeling
- The `host_info` collects host hardware info and insert into the database. It only runs once during the installation time.

Data columns | Description
------------ |------------
hostname | The host name
cpu_number | The number of cores the host's CPU has
cpu_architecture | The host's CPU architecture
cpu_model | The host's CPU model
cpu_mhz | The host's CPU clock speed
l2_cache | The L2 cache size in KB
total_mem | The host's total memory
timestamp | Current timestamp

- The `host_usage` collects current host usage (CPU and Memory) and insert into the database. It is triggered by crontab job every minute.

Data columns | Description
------------|------------
timestamp | UTC time zone
host_id | host id from `hosts` table
memory_free | Free memory in MB
cpu_idle | in percentage
cpu_kernel | in percentage
disk_io | number of disk I/O
disk_available | root directory available disk in MB. 

## Scripts
- psql_docker.sh

This script manages the creation, starting and stopping of the docker container


    # create a psql docker container with the given username and password
    ./scripts/psql_docker.sh create db_username db_password
    
    # start the stopped psql docker container
    ./scripts/psql_docker.sh start

    # stop the running psql docker container
    ./scripts/psql_docker.sh stop


- host_info.sh


    This script is used to insert the host info data into the PostgreSQL database
        
```console
03:16:47 centos: $ psql -h $psql_host -p $psql_port -U $psql_user -d $db_name -c "$insert_stmt"
```

- host_usage.sh


    This script is used to insert the host usage data into the PostgreSQL database
    
```console
03:16:47 centos: $ psql -h $psql_host -p $psql_port -U $psql_user -d $db_name -c "$insert_stmt"
```

- crontab

    
    Used to execute a job. In this case, we use it to collect host data usage every minute. 
```console
03:16:47 centos: $ crontab -e
03:16:47 centos: $ crontab -l
```

- queries.sql (describe what business problem you are trying to resolve)


    The first query groups hosts by cpu_number, in descending order based on memory size.
    The second query computes the average memory usage for each host, within a 5 minute period.

## Improvements 
- handle hardware update 
- check for failed nodes
- collect more data
