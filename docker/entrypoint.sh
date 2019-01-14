#!/bin/sh
set -ex

# Copy psql password file into place

cp /run/secrets/psql_pwfile ~/.pgpass
chmod 0600 ~/.pgpass
if [ ! -f /etc/ofelia.conf ]; then
# Schedule Backup job
  cat <<EOF > /etc/ofelia.conf
[job-local "pg base backup"]
schedule = ${BACKUP_SCHEDULE}
command = wal-e backup-push /pgdata
EOF

fi

# Start ofelia in daemon mode 
/ofelia_linux_amd64/ofelia daemon
