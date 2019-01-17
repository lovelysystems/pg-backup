set -ex

postgres_container=`docker ps -aq --filter "name=localdev_postgres"`
backup_container=`docker ps -aq --filter "name=localdev_pg_backup"`

echo "Creating a new backup"
docker exec ${backup_container} /bin/sh -c 'wal-e backup-push /pgdata'

echo "Stopping Postgres Conatiner"
docker stop ${postgres_container}

echo "Deleting Database"
docker exec ${backup_container} /bin/sh -c 'rm -rf /pgdata/*'

echo "Starting Postgres Container to create a new empty DB"
docker start ${postgres_container}

echo "Please press Enter to continue restoring the old DB"
read tmp

echo "Stopping Postgres Conatiner"
docker stop ${postgres_container}

echo "Restore Backup"
docker exec ${backup_container} /bin/sh -c 'restore.sh LATEST'

echo "Start Postgres container again"
docker start ${postgres_container}
