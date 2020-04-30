#!/usr/bin/env bash

help () {
    echo 'There are 4 available options:'
    echo
    echo '-f (required) -- path to file'
    echo '-c (required) -- running container name'
    echo '-p            -- port'
    echo '-o            -- additional options for mongodump command; wrap in double quotas all the options'
}

if [ $1 == '--help' ]
 then
    help
    exit
fi

declare -a file_check
file_check=0
container_check=0

while getopts :c:p:f:o: option
  do
    case "${option}"
        in
        c)
            CONTAINER=${OPTARG}
            container_check=1
            ;;
        p) PORT=${OPTARG};;
        o) OPTIONS=${OPTARG};;
        f)
            FILEPATH=${OPTARG}
            file_check=1
            ;;
        :)
            echo "Option $option have to be set"
            help
            exit
            ;;
        esac
done

if [[ $file_check == 0 || $container_check == 0 ]]
then
    echo "-f and -c options must be set"
    help
    exit
fi

PORT=${PORT:-27017}
OPTIONS=${OPTIONS:-""}

echo $FILEPATH

echo $CONTAINER
echo $PORT

if [ -f $FILEPATH ]
    then
        read -p "The database will be DROPPED. Proceed? [Y/n]" DROPDB
        if [[ $DROPDB == "n" ]]
            then
                exit
        fi

        cat $FILEPATH | docker exec -i $CONTAINER mongorestore --host localhost --port $PORT --archive --gzip --drop $OPTIONS
    else
        echo "Such file doesn't exists!"
fi
