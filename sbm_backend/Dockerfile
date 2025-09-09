FROM python:3.12-slim

# Set the working directory inside the container.
WORKDIR /usr/src/sbm_backend

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install netcat-openbsd, curl (for healthcheck) and clean up apt cache to reduce image size.
RUN apt-get update \
    && apt-get install -y netcat-openbsd curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install uv, the fast, Rust-based Python package installer.
RUN pip install --upgrade pip
RUN pip install uv

# Copy only the dependency file first to leverage Docker's layer caching.
COPY ./pyproject.toml .

# Install the project dependencies using uv.
RUN uv sync

# Copy gunicorn configuration
COPY ./gunicorn.conf.py .

# Copy entrypoint.sh and make it executable
COPY ./entrypoint.sh .
RUN chmod +x /usr/src/sbm_backend/entrypoint.sh

# Copy the rest of your Django project files into the container.
COPY . .

# Use the entrypoint script to run migrations and start the server.
ENTRYPOINT [ "/usr/src/sbm_backend/entrypoint.sh" ]
