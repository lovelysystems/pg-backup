# docker-pg-backup

This container can be utilized to create base backups for a 
[postgres](https://www.postgresql.org/) instance which is configured to do
[continuous archiving](https://www.postgresql.org/docs/9.2/continuous-archiving.html).

## Usage

### psql

The container can be deployed beside the postgres instance. The postgres 
data directory must be mounted to /pgdata. To configure psql inside the 
backup container following environment variables must be set.

* PGUSER 
* PGHOST

The password can either be specified via a 
[pgpass](https://www.postgresql.org/docs/current/libpq-pgpass.html) file 
or the PGPASSWORD variable. The entrypoint script is looking for a pgpass
file in /run/secrets/pgpass and copies it into the right directory if it
exists. For further information please look at the postgres documentation:

* [Environment Variables](https://www.postgresql.org/docs/current/libpq-envars.html) 
* [pgpass](https://www.postgresql.org/docs/current/libpq-pgpass.html)

### wal-e

Wal-e needs a couple environment variables to work:

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* WALE_S3_PREFIX: s3://{bucketname}/{path to where backups should be placed}
* WALE_S3_ENDPOINT: http+path://minio:9000 // only needed for non s3 urls

At the moment only the packages for s3 are installed. Wal-e supports a couple other 
providers which could be installed if needed. For further configuration options 
please look [here](https://github.com/wal-e/wal-e)

### ofelia

The entrypoint can create a minimal ofelia config if needed. By setting
BACKUP_SCHEDULE to a cron like [schedule](https://godoc.org/github.com/robfig/cron)
a backup will be created according to it. If you'd also like to delete older
backups you can set BACKUPS_TO_RETAIN to a non negative integer doing
this will create a job which keeps the number of backups specified 
and deletes the older ones.

If you need a more specific setup you can mount your own ofelia.conf file at 
/etc/ofelia.conf. If this file exists the entrypoint won't touch it.

For further information about [ofelia](https://github.com/mcuadros/ofelia) please visit their github page.

### restore

To restore the db a couple of steps must be taken:

* create a new empty postgres instance
* mount the data directory into the backup container
* make sure postgres isn't running
* use wal-e backup-fetch /pgdata LATEST to restore the latest backup
* place a recovery.conf file in the /pgdata directory
* start postgres

To make this all a bit easier a script is located at /usr/local/bin/restore
It needs the RESTORE_COMMAND variable to be set to the correct command to 
restore the wal files. Which it uses to create the 
[recovery.conf](https://www.postgresql.org/docs/9.2/continuous-archiving.html) 
file and place it inside the /pgdata directory. The backup can be specified as 
the first argument for the script. For example `restore LATEST`.

The whole scenario can be tested by starting everything with ./gradlew localDev.
Making some changes to the Database and then executing the test_backup.sh script.
This script creates a new Backup then deletes the whole pgdata directory contents
restarting the postgres container to create a fresh Database, stopping it and
restoring the backup, afterwards starting postgres again. At this point postgres 
should fetch all missing wal files and then be in the same state as before starting
the script.

## check backup status

It's possible to use the check_backup command inside the container to check if
the backups reached the specified aws bucket. It needs two extra environment
variables to be set:
* BASE_BACKUP_INTERVAL_MINUTES (Default = 10080 = 1 week)
  * scripts checks if the last backup isn't older than the interval + 5 minutes
* CHECKPOINT_TIMEOUT_SECONDS (Default = 300 -> default in postgres)
  * corresponds to the postgres setting `checkpoint_timeout`, after this time
    postgres needs to create a new wal file and archive the old
  * script checks if the last wal file archived isn't older than the
    timeout + 2 minutes.
