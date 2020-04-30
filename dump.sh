help () {
    echo 'There are 4 available options:'
    echo
    echo '-c (required) -- running container name'
    echo '-p            -- port'
    echo '-d            -- database name; if not set - all database will be dumped'
    echo '-o            -- additional options for mongodump command; wrap in double quotas all the options'
}

if [ $1 == '--help' ]
 then
    help
    exit
fi

container_check=0

while getopts :c:d:o: option
  do
    case "${option}"
        in
        c) CONTAINER=${OPTARG}; container_check=1;;
        p) PORT=${OPTARG};;
        d) DBNAME=${OPTARG};;
        o) OPTIONS=${OPTARG};;
        :)
            echo "Option $option has to be set"
            help
            exit
            ;;
        esac
done


if [[ $container_check == 0 ]]
then
    echo "-c option must be set"
    help
    exit
fi

PORT=${PORT:-27017}
OPTIONS=${OPTIONS:-""}
if [ -n DBNAME ]
 then DB="--db=$DBNAME"
 else DB=""
fi

docker exec ${CONTAINER} /bin/bash -c "mongodump --host localhost --port ${PORT} --archive --gzip $DB $OPTIONS" | \
   cat > dump_${CONTAINER}__${DBNAME}_$(date '+%Y-%m-%d_%H-%M-%S').archive
