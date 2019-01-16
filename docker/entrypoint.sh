#!/bin/sh
set -ex

# Copy psql password file into place

if [ -f /run/secrets/pgpass ]; then 
  cp /run/secrets/pgpass ~/.pgpass
  chmod 0600 ~/.pgpass
fi

if [ ! -f /etc/ofelia.conf ]; then
# Schedule Backup job
  cat <<EOF > /etc/ofelia.conf
[job-local "pg base backup"]
schedule = ${BACKUP_SCHEDULE}
command = wal-e backup-push /pgdata
EOF
  if [ -n "$BACKUPS_TO_RETAIN" ]; then
    cat <<EOF >> /etc/ofelia.conf
[job-local "pg base prune backups"]
schedule = ${BACKUP_SCHEDULE}
command = wal-e delete --confirm retain ${BACKUPS_TO_RETAIN}
EOF
  fi

fi

# Start ofelia in daemon mode 
/ofelia_linux_amd64/ofelia daemon
