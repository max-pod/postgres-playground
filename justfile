# Justfile

# Load environment variables from .env
set dotenv-load := true
set dotenv-required := true

# Use Bash shell
set shell := ['bash', '-cu']

default:
  just --list

# Start the containers
up:
    docker-compose up -d

# Stop and remove the containers
down:
    docker-compose down

# Build or rebuild services
build:
    docker-compose build

# Reset the database
reset-db:
    set -euo pipefail
    echo "🗑️  Terminating existing connections..."
    docker exec ${POSTGRES_CONTAINER_NAME} psql -U ${POSTGRES_USER} -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${POSTGRES_DB}' AND pid <> pg_backend_pid();"
    echo "🗑️  Resetting database..."
    docker exec -it ${POSTGRES_CONTAINER_NAME} psql \
        -U ${POSTGRES_USER} \
        -d postgres \
        -c "DROP DATABASE IF EXISTS ${POSTGRES_DB};"
    docker exec -it ${POSTGRES_CONTAINER_NAME} psql \
        -U ${POSTGRES_USER} \
        -d postgres \
        -c "CREATE DATABASE ${POSTGRES_DB};"
    echo "✨ Database reset complete!" 

# View output from containers
logs:
    docker-compose logs -f

# List containers
ps:
    docker-compose ps

# Rebuild the containers
rebuild:
    just down
    just build
    just up

# Remove all containers, networks, and images
clean:
    docker-compose down -v --rmi all --remove-orphans

# Run local pgcli
pgcli:
    @echo "Running server with postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:5432/$POSTGRES_DB"
    docker exec -it ${POSTGRES_CONTAINER_NAME} pgcli "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:5432/${POSTGRES_DB}"

# Run a specific SQL file
run-sql file:
    @echo "🔧 Running {{file}}..."
    docker exec -i ${POSTGRES_CONTAINER_NAME} psql \
        -U ${POSTGRES_USER} \
        -d ${POSTGRES_DB} \
        < "sql/{{file}}"
    @echo "✨ SQL execution complete!"

# List available SQL files
list-sql:
    @echo "📜 Available SQL files:"
    @ls -1 sql/*.sql | sed 's|sql/||'

# Create a new SQL file
new-sql filename:
    @echo "📝 Creating new SQL file: {{filename}}"
    @touch "sql/{{filename}}.sql"
    @echo "-- Created on $(date)\n\n" > "sql/{{filename}}.sql"

# Display help
help:
    @echo "Available commands:"
    @echo "  just up       - Start the containers"
    @echo "  just down     - Stop and remove the containers"
    @echo "  just build    - Build or rebuild services"
    @echo "  just logs     - View output from containers"
    @echo "  just ps       - List containers"
    @echo "  just rebuild  - Rebuild the containers"
    @echo "  just clean    - Remove all containers, networks, and images"
    @echo "  just pgcli    - Connect to the db locally"
    @echo "  just run-sql  - Run a specific SQL file"
    @echo "  just list-sql - List available SQL files"
    @echo "  just new-sql  - Create a new SQL file"
