cd /opt/time
docker compose stop
mkdir -p /mnt/backup/time/
cp -r data/* /mnt/backup/time/
docker compose start 


cd /opt/auth
docker compose stop lldap
mkdir -p /mnt/backup/lldap/
cp -r data/* /mnt/backup/lldap/
docker compose start 

cd /opt/crates
docker compose stop
mkdir -p /mnt/backup/crates
cp -r data/* /mnt/backup/crates/
docker compose start 