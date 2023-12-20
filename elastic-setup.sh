while getopts u:h: option
do
    case "${option}" in
        u) ELASTIC_USER=${OPTARG};;
        h) ELASTIC_HOST=${OPTARG};;
    esac
done

if [ -z $ELASTIC_HOST ]; then
  echo '-h for elastic host required'
  exit
fi

if [ -z $ELASTIC_USER ]; then
  echo '-u for elastic user required'
  exit
fi

if [ ! -f config/certs/ca.zip ]; then
  echo "Creating CA";
  bin/elasticsearch-certutil ca --silent --pem -out config/certs/ca.zip;
  unzip config/certs/ca.zip -d config/certs;
fi;
if [ ! -f config/certs/certs.zip ]; then
  echo "Creating certs";
  echo -ne \
  "instances:\n"\
  "  - name: es01\n"\
  "    dns:\n"\
  "      - es01\n"\
  "      - localhost\n"\
  "    ip:\n"\
  "      - 127.0.0.1\n"\
  "  - name: kibana\n"\
  "    dns:\n"\
  "      - kibana\n"\
  "      - localhost\n"\
  "    ip:\n"\
  "      - 127.0.0.1\n"\
  "  - name: fleet-server\n"\
  "    dns:\n"\
  "      - fleet-server\n"\
  "      - localhost\n"\
  "    ip:\n"\
  "      - 127.0.0.1\n"\
  > config/certs/instances.yml;
  bin/elasticsearch-certutil cert --silent --pem -out config/certs/certs.zip --in config/certs/instances.yml --ca-cert config/certs/ca/ca.crt --ca-key config/certs/ca/ca.key;
  unzip config/certs/certs.zip -d config/certs;
fi;
echo "Setting file permissions"
chown -R root:root config/certs;
find . -type d -exec chmod 750 \{\} \;;
find . -type f -exec chmod 640 \{\} \;;
echo "Waiting for Elasticsearch availability";
until curl -s --cacert config/certs/ca/ca.crt $ELASTIC_HOST | grep -q "missing authentication credentials"; do sleep 30; done;
echo "All done!";
chmod 755 elastic-setup.sh;
