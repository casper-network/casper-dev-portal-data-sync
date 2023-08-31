# Casper Dev Portal Data Sync

This utility is designed to synchronize the contents of an Amazon S3 source bucket to a target S3 bucket, invalidate the target S3 bucket's CloudFront distribution, and sync two MariaDB database instances (Directus). It is implemented in Python and Bash.

This is needed when changes have been done on the staging environment and need to be replicated to the production environment.

It can be used in any environment where:

- Directus is used to manage content
- Directus assets are stored in an Amazon S3 bucket.
- The Directus database needs to be replicated to a target database (env to env replication keeping the directus_users table intact).
- The target database is used by a Directus instance that is configured to use the target S3 bucket.
- The target S3 bucket is used by a CloudFront distribution.

## DISCLAIMER

This utility is provided "as-is" without any guarantees or warranties. Users are advised to exercise caution as the utility may not work in all environments and could potentially harm your data. The author(s) or the organization owning the repository disclaims all liability for any damage resulting from its use. By using this utility, you assume all risks and responsibilities and agree not to hold the author(s) or the organization liable for any damages incurred.

## How it Works

The utility consists of two scripts: [repl.sh](repl.sh) and [sync_buckets.py](sync_buckets.py).
The [repl.sh](repl.sh) script replicates the database from the source to the target, and then calls the [sync_buckets.py](sync_buckets.py) script to synchronize the S3 buckets and invalidate the CloudFront distribution.

The [sync_buckets.py](sync_buckets.py) script deletes all objects in the target bucket, copies all objects from the source bucket to the target bucket, and invalidates the CloudFront distribution.

**ATTENTION**: **The target bucket is completely emptied before the synchronization. This means that any objects that exist in the target bucket but not in the source bucket will be deleted. This is done to ensure that the target bucket is an exact copy of the source bucket.**

**ATTENTION**: **The target database is completely overwritten except for the directus_users table. This means that any data that exists in the target database but not in the source database will be deleted. This is done to ensure that the target database is an exact copy of the source database.**

## Prerequisites

- Python 3
- Boto3
- AWS account with access to S3 and CloudFront
- Two S3 buckets (source and target)
- A CloudFront distribution pointing to the target bucket
- Source and target databases (MySQL or MariaDB)
- mysqldump and MySQL client for database operations
- **Optional:** `pv` (utility to monitor the progress of data through a pipeline 

## Dependencies

### Python 3

The scripts are written in Python 3. You should have Python 3 installed on your system. On Ubuntu, you can install it using:

```bash
sudo apt-get install python3
```

### Boto3

Boto3 is the Amazon Web Services (AWS) Software Development Kit (SDK) for Python, which allows Python developers to write software that makes use of services like Amazon S3, Amazon EC2, and others.

You can install Boto3 using pip:

```bash
pip install boto3
```

Alternatively, you can install it using the requirements.txt file:

```bash
pip install -r requirements.txt
```

### mysqldump and MySQL client

The scripts use mysqldump and the MySQL client to replicate the database. You can install them on Ubuntu using:

```bash
sudo apt-get install mariadb-client
```

### pv (optional)

pv is a terminal-based tool for monitoring the progress of data through a pipeline. It can be optionally installed to see the progress of the database import. On Ubuntu, you can install it using:

```bash
sudo apt-get install pv
```

## Configuration

The scripts use environment variables to get the necessary AWS, S3 bucket, and database information. You need to rename the [env.sh.example] file to `env.sh` and fill in the required variables.

## Running the Scripts

After setting up the environment variables, you can run the [repl.sh]  script:

```bash
./repl.sh
```

This script will first replicate the database from the source to the target. If you have pv installed, you will see the progress of the import.

Then, it will call the sync_buckets.py script to delete all objects in the target bucket, copy all objects from the source bucket to the target bucket, and invalidate the CloudFront distribution, effectively synchronizing the buckets, distribution, and databases.
