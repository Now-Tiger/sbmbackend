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

## Frontend

Change directory into frontend and follow below steps one by one. This starts the frontend locally.

```Bash
npm install
npm run dev
```

Visit `http://localhost:3000` on your browser.

# APIs

The backend has two built in APIs. One third party api in used by the frontend only.

1. `http://localhost:8000/` : root API, also used as the health check API.
2. `http://localhost:8000/user-analytics` : Returns the data from `user_analytics` table from the `sbmdb` Postgres database.
3. `https://data-api.coindesk.com/index/cc/v1/latest/tick?market=cadli&instruments=BTC-USD,ETH-USD&apply_mapping=true` : This is a **Third-Party** API used to fetch crypto data.

# Frontend App structure

- On startup you have a Navbar with few options, and a card that displays two buttons.
- `Fetch data` button and `Dashboard` navbar item redirects you the `../analytics` page.
- `Add data` button and `App` navbar item redirects you to the `../app` page.

#### Analytics page

- Analytics page has displays three cards/charts.
- First card, displaying vertical bar chart, displays the data returned by backend API call i.e. `http://localhost:8000/user-analytics/`
- Second card, displaying horizontal bar chart, shows static data (No API call)
- Third & last card, displays area chart, shows data from **Third-party** [crypto market data API](https://developers.coindesk.com/documentation/data-api/index_cc_v1_latest_tick)

#### App page

- On app page, you have a form. After adding the data you can see that data on the first bar chart displayed on the Analytics page.
- The form data is sent to `http://localhost:8000/user-analytics` API using `POST` method, on successful API call the API returns the data that is being sent via API and that data can be displayed on Analytics page.
- To see this in action, add larger quantities/numbers for desktop or mobile fields for the month of January 2024.
