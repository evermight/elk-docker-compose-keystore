while getopts u:h:p:k:a: option
do
    case "${option}" in
        u) ELASTIC_USER=${OPTARG};;
        h) ELASTIC_HOST=${OPTARG};;
        p) ELASTIC_PASSWORD=${OPTARG};;
        k) ENCRYPTION_KEY=${OPTARG};;
        a) APM_TOKEN=${OPTARG};;
    esac
done

if [ -f /usr/share/kibana/keystore/kibana.keystore ]; then
  echo "All done! Keystore exists."
  sleep 120;
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

if [ -z $ENCRYPTION_KEY ]; then
  echo '-k for encryption key required'
  exit
fi

#if [ -z $APM_TOKEN ]; then
#  echo '-a for apm token required'
#  exit
#fi

curl -s -X DELETE --cacert config/certs/ca/ca.crt -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" ${ELASTIC_HOST}/_security/service/elastic/kibana/credential/token/kibana_token;
curl -s -X POST --cacert config/certs/ca/ca.crt -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" ${ELASTIC_HOST}/_security/service/elastic/kibana/credential/token/kibana_token -o result;
/usr/share/kibana/bin/kibana-keystore create;
cat result | grep -oP '"value":"\K[^"]+' | sed 's/\\"/"/g' | /usr/share/kibana/bin/kibana-keystore add elasticsearch.serviceAccountToken -x;
echo $ENCRYPTION_KEY | /usr/share/kibana/bin/kibana-keystore add xpack.security.encryptionKey -x;
echo $ENCRYPTION_KEY | /usr/share/kibana/bin/kibana-keystore add xpack.encryptedSavedObjects.encryptionKey -x;
echo $ENCRYPTION_KEY | /usr/share/kibana/bin/kibana-keystore add xpack.reporting.encryptionKey -x;
#echo $APM_TOKEN | /usr/share/kibana/bin/kibana-keystore add elastic.apm.secretToken -x;
#echo $APM_TOKEN | /usr/share/kibana/bin/kibana-keystore add xpack.fleet.agentPolicies[0].package_policies[3].inputs[0].vars[1].value -x;
rm result;
#cp result /usr/share/kibana/keystore/;
cp /usr/share/kibana/config/kibana.keystore /usr/share/kibana/keystore/kibana.keystore;
chmod 777 /usr/share/kibana/keystore/kibana.keystore;
echo "All done!";
sleep 120;
