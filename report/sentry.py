import os

import sentry_sdk

from report._version import get_version


def load_sentry():
    """Load Sentry integration."""

    if sentry_dsn := os.environ.get("SENTRY_DSN"):
        sentry_sdk.init(
            dsn=sentry_dsn,
            # Enable Sentry's "Releases" feature, see:
            # https://docs.sentry.io/platforms/python/configuration/options/#release
            release=get_version(),
        )
