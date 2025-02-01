# We need to match the version inside the metabase image in order for the
# libraries which Python is built against to exist
FROM python:3.11.11-alpine3.19 AS python

# We'll build/install all python dependencies in the python image
COPY requirements/prod.txt ./
RUN apk add --virtual build-deps \
    build-base \
    postgresql-dev \
    python3-dev \
    libffi-dev \
  && pip3 install --no-cache-dir -U pip \
  && pip3 install --no-cache-dir -r prod.txt \
  && apk del build-deps


FROM metabase/metabase:v0.52.8.5

# Copy the python binaries and libraries from the python image
# The metabase image is based on a newer alpine and the python package there
# won't point to the exact version we need.
COPY --from=python /usr/local/bin/python3 /usr/local/bin/python3
COPY --from=python /usr/local/bin/python3.11 /usr/local/bin/python3.11
COPY --from=python /usr/local/bin/python /usr/local/bin/python

COPY --from=python /usr/local/lib/python3.11/ /usr/local/lib/python3.11/
COPY --from=python /usr/local/lib/libpython3.11.so.1.0 /usr/local/lib/libpython3.11.so.1.0
COPY --from=python /usr/local/lib/libpython3.so /usr/local/lib/libpython3.so

# Make sure various scripts we use from Python packages are available
COPY --from=python /usr/local/bin/newrelic-admin /usr/local/bin/newrelic-admin

# We need to install some package that are not present in the metabase image
RUN apk add libpq

# Create the report user, group, home directory and package directory.
RUN addgroup -S report \
  && adduser -S -G report -h /var/lib/report report
WORKDIR /var/lib/report


# Copy the rest of the python application files.
COPY . .

ENV PYTHONPATH=/var/lib/report:$PYTHONPATH
