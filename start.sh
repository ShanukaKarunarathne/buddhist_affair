#!/bin/bash
set -e

echo "Starting application..."

# Wait for database to be ready
echo "Waiting for database..."
until pg_isready -h $(echo $DATABASE_URL | sed -E 's/.*@([^:]+).*/\1/') -U $(echo $DATABASE_URL | sed -E 's/.*\/\/([^:]+).*/\1/'); do
  echo "Database is unavailable - sleeping"
  sleep 2
done

echo "Database is up - executing migrations"
alembic upgrade head

echo "Starting Uvicorn server"
uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}