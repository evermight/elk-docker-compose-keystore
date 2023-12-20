docker cp es-es01-1:/usr/share/elasticsearch/config/certs/ca/ca.crt /tmp/.
openssl x509 -fingerprint -sha256 -noout -in /tmp/ca.crt | awk -F"=" {' print $2 '} | sed s/://g
cat /tmp/ca.crt
