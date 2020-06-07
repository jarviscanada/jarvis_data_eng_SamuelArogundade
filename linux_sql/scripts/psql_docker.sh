#!/bin/bash

# script usage
#./scripts/psql_docker.sh start|stop|create [db_username][db_password]


#start docker if docker server is not running
systemctl status docker || systemctl start docker


#function to check container existence
checkContainer () {
    if [[ `docker container ls -a -f name=jrvs-psql | wc -l` == 2 ]]; then
        return 0
    fi
    return 1
}


#checks user's command
if [[ "$1" == "create" ]]; then
    #checks if container has been created already
    if [[ `checkContainer` == 0 ]]; then
        echo "Container already exists. Script usage is \"./scripts/psql_docker.sh start|stop|create [db_username][db_password]\""
        exit 1
    fi

    #checks if user has username and password args
    if [[ -z "$2" || -z "$3" ]]; then
        echo "Invalid arguments passed. Script usage is \"./scripts/psql_docker.sh start|stop|create [db_username][db_password]\""
        exit 1
    fi

    #creates volume
    docker volume create pgdata

    #stores username and password args
    db_username=$2
    db_password=$3

    #creates container
    docker run --name jrvs-psql -e POSTGRES_PASSWORD=${db_password} -e POSTGRES_USER=${db_username} -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres

    #exits with the value of the execute command
    exit $?
fi


#checks if container exists
if [[ `checkContainer` == 1 ]]; then
        echo "Container has not been created yet. Script usage is \"./scripts/psql_docker.sh start|stop|create [db_username][db_password]\""
        exit 1
fi

#checks user's command
if [[ "$1" == "start" ]]; then
    #checks if container exists
    if [[ `checkContainer` == 1 ]]; then
        echo "Container has not been created yet. Script usage is \"./scripts/psql_docker.sh start|stop|create [db_username][db_password]\""
        exit 1
    fi
    
    #starts container
    docker container start jrvs-psql
    
    #exits with the value of the execute command
    exit $?
fi

#checks user's command
if [[ "$1" == "stop" ]]; then
    #stops container
    docker container stop jrvs-psql
    
    #exits with the value of the execute command
    exit $?
fi


#user's command didn't match the script usage   
if [[ -z "$1" || "$1" ]]; then
    echo "Invalid arguments passed. Script usage is \"./scripts/psql_docker.sh start|stop|create [db_username][db_password]\""
    exit 1
fi

