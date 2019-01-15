set -ex

wal-e backup-fetch /pgdata $1 

cat <<EOF > /pgdata/recovery.conf
restore_command = '${RESTORE_COMMAND}'
EOF
