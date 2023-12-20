while getopts u:h:p:b:m: option
do
    case "${option}" in
        u) ELASTIC_USER=${OPTARG};;
        h) ELASTIC_HOST=${OPTARG};;
        p) ELASTIC_PASSWORD=${OPTARG};;
        b) BEAT=${OPTARG};;
        m) USER_EMAIL=${OPTARG};;
    esac
done

if [ -z $BEAT ]; then
  echo '-b for beat type required: metricbeat, filebeat, auditbeat, packetbeat, or heartbeat '
  exit
fi

if [ -f /usr/share/"$BEAT"/data/"$BEAT".keystore ]; then
  echo "All done! Keystore exists."
  sleep 10;
  exit;
fi

if [ -z $ELASTIC_HOST ]; then
  echo '-h for elastic host required'
  exit
fi

if [ -z $ELASTIC_USER ]; then
  echo '-u for elastic user required'
  exit
fi

if [ -z $ELASTIC_PASSWORD ]; then
  echo '-p for elastic password required'
  exit
fi

if [ -z $USER_EMAIL ]; then
  echo '-m for user email required'
  exit
fi

ARRAY=('a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
userpass=""
for i in {1..10}; do
  userpass+="${ARRAY[$RANDOM % ${#ARRAY[@]}]}"
done

if [ ! -f /usr/share/"$BEAT"/data/"$BEAT".keystore ]; then
  curl -s -X POST $ELASTIC_HOST/_security/role/"$BEAT"_publish \
    --cacert ./certs/ca/ca.crt \
    -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
    -H "Content-Type: application/json" \
    -d '{"cluster": ["read_ilm","monitor","read_pipeline"],"indices": [{"names":["'"$BEAT"'-*"],"privileges":["create_doc"],"allow_restricted_indices":false}],"applications": []}';

  curl -X POST $ELASTIC_HOST/_security/user/"$BEAT"_publisher \
    --cacert ./certs/ca/ca.crt \
    -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
    -H "Content-Type: application/json" \
    -d '{"password" : "'"$userpass"'","roles" : ["'"$BEAT"'_publish","editor"],"full_name" : "'"$BEAT"'_publisher","email" : "'"$USER_EMAIL"'","metadata" : {}}';

  curl -X POST $ELASTIC_HOST/_security/user/"$BEAT"_setup \
    --cacert ./certs/ca/ca.crt \
    -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
    -H "Content-Type: application/json" \
    -d '{"password" : "'"$userpass"'","roles" : ["superuser"],"full_name" : "'"$BEAT"'_setup","email" : "'"$USER_EMAIL"'","metadata" : {}}';

  echo $userpass | /usr/share/"$BEAT"/"$BEAT" keystore add BEAT_PASS --force --stdin
fi;
echo "All done!";
sleep 10;
