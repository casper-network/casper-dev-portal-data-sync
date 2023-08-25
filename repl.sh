#!/bin/bash

set -e
set -o pipefail

echo "Loading environment variables..."
. ./env.sh

# Check if necessary environment variables are set
for var in SOURCE_DB_HOST SOURCE_DB_USER SOURCE_DB_PASS SOURCE_DB_NAME SOURCE_EXCLUDE_TABLE DEST_DB_HOST DEST_DB_USER DEST_DB_PASS DEST_DB_NAME; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set." >&2
        exit 1
    fi
done

echo "Dumping tables from source database..."
mysqldump -h $SOURCE_DB_HOST -u $SOURCE_DB_USER -p"$SOURCE_DB_PASS" --no-tablespaces --set-gtid-purged=OFF --ignore-table=$SOURCE_DB_NAME.$SOURCE_EXCLUDE_TABLE -P $SOURCE_DB_PORT $SOURCE_DB_NAME > dump.sql

echo "Importing dumped data into destination database..."

# If you have 'pv' (On Ubuntu, it can be installed with: sudo apt-get install pv). you can use it to see the progress of the import. It's better so that you know if's working:
if command -v pv > /dev/null 2>&1; then
    pv dump.sql | mysql -h $DEST_DB_HOST -u "$DEST_DB_USER" -p"$DEST_DB_PASS" $DEST_DB_NAME -P $DEST_DB_PORT
else
    mysql -h $DEST_DB_HOST -u $DEST_DB_USER -p"$DEST_DB_PASS" $DEST_DB_NAME -P $DEST_DB_PORT < dump.sql
fi

echo "Synchronizing buckets..."
./sync_buckets.py

echo "Done."
