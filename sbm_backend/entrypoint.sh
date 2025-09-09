#!/bin/sh

if [ "$DATABASE" = "postgres" ]; then
  echo "Check if database is running..."

  while ! nc -z $SQL_HOST $SQL_PORT; do
    sleep 0.1
  done

  echo "The database is up and running :-D"
fi

uv run manage.py makemigrations
uv run python manage.py migrate

# Collect static files (important for production)
uv run python manage.py collectstatic --noinput

# Start Gunicorn
echo "Starting Gunicorn..."
exec uv run gunicorn sbm_backend.wsgi:application -c gunicorn.conf.py
