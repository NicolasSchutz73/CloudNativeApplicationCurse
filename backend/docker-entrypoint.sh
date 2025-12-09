#!/bin/sh
set -e

echo "Waiting for database connection..."

# Wait for database to be ready
max_retries=30
retry_count=0

until [ $retry_count -ge $max_retries ]; do
  if npx prisma db execute --stdin 2>/dev/null <<EOF
SELECT 1;
EOF
  then
    echo "Database is ready!"
    break
  fi
  retry_count=$((retry_count + 1))
  echo "Waiting for database... (attempt $retry_count/$max_retries)"
  sleep 2
done

if [ $retry_count -ge $max_retries ]; then
  echo "Failed to connect to database after $max_retries attempts"
  exit 1
fi

# Run Prisma migrations
echo "Running database migrations..."
npx prisma migrate deploy

# Start the application
echo "Starting application..."
exec npm start
