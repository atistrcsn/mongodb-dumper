help () {
    echo 'There are 3 available options:'
    echo
    echo '-c (required) -- running container name'
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

OPTIONS=${OPTIONS:-""}
if [ -n DBNAME ]
 then DB="--db=$DBNAME"
 else DB=""
fi

docker exec ${CONTAINER} /bin/bash -c "mongodump --host localhost --port 27017 --archive --gzip $DB $OPTIONS" | \
   cat > dump_${DBNAME}_$(date '+%d-%m-%Y_%H-%M-%S').archive
