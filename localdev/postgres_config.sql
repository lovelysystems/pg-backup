ALTER SYSTEM SET wal_level TO logical;
ALTER SYSTEM SET archive_mode TO on;
ALTER SYSTEM SET archive_command TO 'test ! -f /archive/%f && cp %p /archive/%f';
ALTER SYSTEM SET archive_timeout TO 60;
