while getopts u:h:p:m: option
do
    case "${option}" in
        u) ELASTIC_USER=${OPTARG};;
        h) ELASTIC_HOST=${OPTARG};;
        p) ELASTIC_PASSWORD=${OPTARG};;
        m) USER_EMAIL=${OPTARG};;
    esac
done

if [ -f /usr/share/logstash/keystore/logstash.keystore ]; then
  echo "All done! Keystore exists."
  sleep 10;
  exit;
fi;
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

if [ ! -f /usr/share/logstash/keystore/logstash.keystore ]; then

  curl -X POST $ELASTIC_HOST/_security/user/logstash_publish \
    --cacert ./certs/ca/ca.crt \
    -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
    -H "Content-Type: application/json" \
    -d '{"password" : "'"$userpass"'","roles" : ["superuser"],"full_name" : "logstash_publish","email" : "'"$USER_EMAIL"'","metadata" : {}}';

#  export LOGSTASH_KEYSTORE_PASS=ABCD1234
  echo "y" | /usr/share/logstash/bin/logstash-keystore create;
  echo $userpass | /usr/share/logstash/bin/logstash-keystore add OUTPUT_PASS
  cp /usr/share/logstash/config/logstash.keystore /usr/share/logstash/keystore/logstash.keystore
# chmod 777 /usr/share/logstash/keystore/logstash.keystore;
fi;
echo "All done!";
sleep 10;
