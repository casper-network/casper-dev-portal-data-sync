# Use an official Python runtime as a parent image
FROM python:3.12-slim-bullseye

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY repl.sh /app
COPY requirements.txt /app
COPY sync_buckets.py /app

RUN apt-get update && \
    apt-get install -y bash mariadb-client pv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd jobuser && \
    mkdir /home/jobuser && \
    chown jobuser:jobuser /home/jobuser && \
    chown -R jobuser:jobuser /app && \
    mkdir -p /home/jobuser/.aws && \
    echo "[default]" > /home/jobuser/.aws/config && \
    echo "region = ${AWS_DEFAULT_REGION}" >> /home/jobuser/.aws/config && \
    echo "[${AWS_PROFILE}]" > /home/jobuser/.aws/credentials && \
    echo "aws_access_key_id = ${AWS_ACCESS_KEY_ID}" >> /home/jobuser/.aws/credentials && \
    echo "aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" >> /home/jobuser/.aws/credentials && \
    chown -R jobuser:jobuser /home/jobuser/.aws && \
    chmod 400 /home/jobuser/.aws/config && \
    chmod 400 /home/jobuser/.aws/credentials && \
    chmod +x /app/repl.sh && \
    chmod +x /app/sync_buckets.py

# Switch to jobuser for subsequent commands
USER jobuser

# Run repl.sh when the container launches
CMD ["./repl.sh"]
