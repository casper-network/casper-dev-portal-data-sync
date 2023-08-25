# Use an official Python runtime as a parent image
FROM python:3.10-slim-buster

# Set the working directory in the container to /app
WORKDIR /app

# Add bash and mysql client
RUN apt-get update && apt-get install -y bash mysql-client pv && rm -rf /var/lib/apt/lists/*

# Copy the current directory contents into the container at /app
ADD repl.sh /app
ADD requirements.txt /app
ADD sync_buckets.py /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Run repl.sh when the container launches
CMD ["./repl.sh"]