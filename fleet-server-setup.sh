while getopts u:h:p:m:a:t: option
do
    case "${option}" in
        u) ELASTIC_USER=${OPTARG};;
        h) ELASTIC_HOST=${OPTARG};;
        p) ELASTIC_PASSWORD=${OPTARG};;
        m) USER_EMAIL=${OPTARG};;
        a) APM_USER=${OPTARG};;
        t) APM_PASS=${OPTARG};;
    esac
done

if [ -f /usr/share/elastic-agent/keystore/elastic-agent.keystore ]; then
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

if [ -z $APM_USER ]; then
  echo '-a for apm user name required'
  exit
fi

if [ -z $APM_PASS ]; then
  echo '-t for apm password required'
  exit
fi

username=$APM_USER
userpass=$APM_PASS
if [ ! -f /usr/share/elastic-agent/keystore/elastic-agent.initialized ]; then

  curl -X POST $ELASTIC_HOST/_security/user/$username \
    --cacert /usr/share/elastic-agent/certs/ca/ca.crt \
    -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
    -H "Content-Type: application/json" \
    -d '{"password" : "'"$userpass"'","roles" : ["superuser"],"full_name" : "'"$username"'","email" : "'"$USER_EMAIL"'","metadata" : {}}';

  echo "initialized" > /usr/share/elastic-agent/keystore/elastic-agent.initialized;
fi;
echo "All done!";
sleep 60;
