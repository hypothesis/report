import os

import sentry_sdk


def load_sentry():
    """Load Sentry integration."""

    if sentry_dsn := os.environ.get("SENTRY_DSN"):
        sentry_sdk.init(dsn=sentry_dsn)
