# Directus Env Replication Utility

This utility is designed to synchronize the contents of an Amazon S3 source bucket to a target S3 bucket, invalidate a CloudFront distribution, and replicate a database. It is implemented in Python and Bash.

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

### mysqldump and MySQL client

The scripts use mysqldump and the MySQL client to replicate the database. You can install them on Ubuntu using:

```bash
sudo apt-get install mysql-client
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
