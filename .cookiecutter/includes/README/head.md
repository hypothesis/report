Used for internal purposes only.


## Environment variables


| Name                              | Example                                | Notes                                           | 
|-----------------------------------|----------------------------------------|-------------------------------------------------|
| `DATABASE_URL`                    | `postgresql://user:pw@host/report`        | Postgres DSN for the report DB                                   |


On top of the service own environment variables these are the metabase variables that we use:


| Name                              | Example                                | Notes                                           | 
|-----------------------------------|----------------------------------------|-------------------------------------------------|
| `MB_DB_DBNAME`                    | `metabase`        | Metabase database name                                   |
| `MB_DB_HOST`                    | `localhost`        | Metabase database host                                   |
| `MB_DB_PASS`                    | `pass`        | Metabase database password                                   |
| `MB_DB_PORT`                    | `5432`        | Metabase database port                                   |
| `MB_DB_TYPE`                    | `postgres`        | Metabase database type. We use `postgres`. |
| `MB_DB_USER`                    | `user`        | Metabase database user                                   |


The full list of supported variables by metabase can be found here:

https://www.metabase.com/docs/latest/configuring-metabase/environment-variables.html
