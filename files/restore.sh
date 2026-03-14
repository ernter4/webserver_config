cp -r /mnt/backup/g1_server/* /opt/time/data/
chown -R 1000:1000 /opt/time/data
cp -r /mnt/backup/lldap/* /opt/auth/data/
chown -R 1000:1000 /opt/auth/data
cp -r /mnt/backup/crates/* /opt/crates/data/
chown -R 1000:1000 /opt/crates/data