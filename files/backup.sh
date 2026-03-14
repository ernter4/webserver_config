cd /opt/time
docker compose down
cp -r data /mnt/nas_backup/time
docker compose up -d


cd /opt/auth
docker compose down
cp -r data /mnt/nas_backup/lldap
docker compose up -d

cd /opt/crates
docker compose down
cp -r data /mnt/nas_backup/crates
docker compose up -d