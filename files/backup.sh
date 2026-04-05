cd /opt/time
docker compose down
mkdir /mnt/backup/time/
cp -r data/* /mnt/backup/time/
docker compose up -d


cd /opt/auth
docker compose down
mkdir /mnt/backup/lldap/
cp -r data/* /mnt/backup/lldap/
docker compose up -d

cd /opt/crates
docker compose down
mkdir /mnt/backup/crates
cp -r data/* /mnt/backup/crates/
docker compose up -d