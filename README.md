# Backend Setup

Follow below steps one by one

#### Build docker images

```bash
docker compose build
```

#### Pull Postgres image

For some reasons `docker-compose.yml` is not able to full postgres image. You'll have to enter below command. **This is an important step**

```bash
docker pull postgres:15.5-alpine
```

#### Start containers

Below command runs the containers in the background.

```bash
docker compose up -d
```

To check if the containers are running, you can use:

```bash
docker compose ps
```

#### Django app logs

```bash
docker logs -f backend-web-1 --tail 50
```

#### Postgres checkup

```bash
docker compose exec db psql -U postgresuser -d sbmdb
```

## Local APIs

The backend has two built in APIs. One third party api in used by the frontend only.

1. `http://localhost:8000/` : root API, also used as the health check API.
2. `http://localhost:8000/user-analytics` : Returns the data from `user_analytics` table from the `sbmdb` Postgres database. API can also be used to make `POST` API call.
3. [Crypto market data API](https://developers.coindesk.com/documentation/data-api/index_cc_v1_latest_tick) : This is a **Third-Party** API used to fetch crypto data.
