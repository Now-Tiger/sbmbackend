#!/bin/sh

if [ "$DATABASE" = "postgres" ]; then
  echo "Waiting for postgres..."

  while ! nc -z $SQL_HOST $SQL_PORT; do
    sleep 0.1
  done

  echo "PostgreSQL started"
fi

# Run migrations
echo "Running migrations..."
uv run python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
uv run python manage.py collectstatic --noinput --clear

# Create superuser if it doesn't exist (optional)
# echo "Creating superuser..."
# uv run python manage.py shell -c "
# from django.contrib.auth import get_user_model
# User = get_user_model()
# if not User.objects.filter(username='admin').exists():
#     User.objects.create_superuser('admin', 'admin@example.com', 'your-admin-password')
# "

exec "$@"
