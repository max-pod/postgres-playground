# Use the official latest PostgreSQL image as the base image
FROM postgres:latest

# Install pgcli using apt
RUN apt-get update && apt-get install -y \
  pgcli \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose the PostgreSQL default port
EXPOSE 5432

# Set the default command to start PostgreSQL
CMD ["postgres"]