Used for internal purposes only.

## Environment variables

| Name                    | Example                                | Notes                                                  |
|-------------------------|----------------------------------------|--------------------------------------------------------|
| `DATABASE_URL`          | `postgresql://user:pw@host/report`     | Postgres DSN for the report DB                         |
| `HUBSPOT_API_KEY`       | `01234567-89ab-cdef-0123-456789abcdef` | API key for integration with Hubspot                   |
| `H_CA_DATABASE_URL`     | `postgresql://user:pw@host/h`          | Connection to H (Canada)                               |
| `H_US_DATABASE_URL`     | `postgresql://user:pw@host/h`          | Connection to H (US)                                   |
| `LMS_CA_DATABASE_URL`   | `postgresql://user:pw@host/lms`        | Connection to LMS (Canada)                             |
| `LMS_US_DATABASE_URL`   | `postgresql://user:pw@host/lms`        | Connection to LMS (US)                                 |
| `MB_DB_USER`            | `metabase`                             | The username Metabase will use to access the report DB |

On top of the service own environment variables these are the metabase variables that we use:

| Name           | Example     | Notes                                      |
|----------------|-------------|--------------------------------------------|
| `MB_DB_DBNAME` | `metabase`  | Metabase database name                     |
| `MB_DB_HOST`   | `localhost` | Metabase database host                     |
| `MB_DB_PASS`   | `pass`      | Metabase database password                 |
| `MB_DB_PORT`   | `5432`      | Metabase database port                     |
| `MB_DB_TYPE`   | `postgres`  | Metabase database type. We use `postgres`. |
| `MB_DB_USER`   | `user`      | Metabase database user                     |

In addition, we are also providing some custom Java options

| Name        | Value                                                     | Description         |
|-------------|-----------------------------------------------------------|---------------------|
| `JAVA_OPTS` | `-Dlog4j.configurationFile=file://conf/report-log4j2.xml` | Custom log4j config |

The full list of supported variables by metabase can be found here:

https://www.metabase.com/docs/latest/configuring-metabase/environment-variables.html
