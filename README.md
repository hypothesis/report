<a href="https://github.com/hypothesis/report/actions/workflows/ci.yml?query=branch%3Amain"><img src="https://img.shields.io/github/workflow/status/hypothesis/report/CI/main"></a>
<a><img src="https://img.shields.io/badge/python-3.8-success"></a>
<a href="https://github.com/hypothesis/report/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-BSD--2--Clause-success"></a>
<a href="https://github.com/hypothesis/cookiecutters/tree/main/pyapp"><img src="https://img.shields.io/badge/cookiecutter-pyapp-success"></a>
<a href="https://black.readthedocs.io/en/stable/"><img src="https://img.shields.io/badge/code%20style-black-000000"></a>

# Report

The internal global reporting product for Hypothesis.

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
| `NEW_RELIC_APP_NAME`    | `report`                               | Report's New Relic name                                |
| `NEW_RELIC_ENVIRONMENT` | `prod`                                 | The environment we are deployed in                     |
| `NEW_RELIC_LICENSE_KEY` | `01234567-89ab-cdef-0123-456789abcdef` | The licence key from New Relic                         |
| `SENTRY_DSN`            | `01234567-89ab-cdef-0123-456789abcdef` | Connection details for Sentry error reporting          |
| `SENTRY_ENVIRONMENT`    | `prod`                                 | The Sentry environment                                 |

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

## Setting up Your Report Development Environment

First you'll need to install:

* [Git](https://git-scm.com/).
  On Ubuntu: `sudo apt install git`, on macOS: `brew install git`.
* [GNU Make](https://www.gnu.org/software/make/).
  This is probably already installed, run `make --version` to check.
* [pyenv](https://github.com/pyenv/pyenv).
  Follow the instructions in pyenv's README to install it.
  The **Homebrew** method works best on macOS.
  The **Basic GitHub Checkout** method works best on Ubuntu.
  You _don't_ need to set up pyenv's shell integration ("shims"), you can
  [use pyenv without shims](https://github.com/pyenv/pyenv#using-pyenv-without-shims).

Then to set up your development environment:

```terminal
git clone https://github.com/hypothesis/report.git
cd report
make devdata
make help
```

## Changing the Project's Python Version

To change what version of Python the project uses:

1. Change the Python version in the
   [cookiecutter.json](.cookiecutter/cookiecutter.json) file. For example:

   ```json
   "python_version": "3.10.4",
   ```

2. Re-run the cookiecutter template:

   ```terminal
   make template
   ```

3. Re-compile the `requirements/*.txt` files.
   This is necessary because the same `requirements/*.in` file can compile to
   different `requirements/*.txt` files in different versions of Python:

   ```terminal
   make requirements
   ```

4. Commit everything to git and send a pull request

## Changing the Project's Python Dependencies

### To Add a New Dependency

Add the package to the appropriate [`requirements/*.in`](requirements/)
file(s) and then run:

```terminal
make requirements
```

### To Remove a Dependency

Remove the package from the appropriate [`requirements/*.in`](requirements)
file(s) and then run:

```terminal
make requirements
```

### To Upgrade or Downgrade a Dependency

We rely on [Dependabot](https://github.com/dependabot) to keep all our
dependencies up to date by sending automated pull requests to all our repos.
But if you need to upgrade or downgrade a package manually you can do that
locally.

To upgrade a package to the latest version in all `requirements/*.txt` files:

```terminal
make requirements --always-make args='--upgrade-package <FOO>'
```

To upgrade or downgrade a package to a specific version:

```terminal
make requirements --always-make args='--upgrade-package <FOO>==<X.Y.Z>'
```

To upgrade **all** packages to their latest versions:

```terminal
make requirements --always-make args=--upgrade
```
