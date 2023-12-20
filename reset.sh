rm -rf keystore/*;
docker-compose down --remove-orphans --volumes && docker-compose up --build -d;
