from unittest.mock import sentinel

import pytest

from report.sentry import load_sentry


class TestLoadSentry:
    def test_it(self, os, sentry_sdk, get_version):
        os.environ = {"SENTRY_DSN": sentinel.sentry_dsn}

        load_sentry()

        sentry_sdk.init.assert_called_once_with(
            dsn=sentinel.sentry_dsn,
            release=get_version.return_value,
        )

    def test_it_with_no_sentry_dsn(self, os, sentry_sdk):
        os.environ = {}

        load_sentry()

        sentry_sdk.init.assert_not_called()


@pytest.fixture(autouse=True)
def os(patch):
    return patch("report.sentry.os")


@pytest.fixture(autouse=True)
def sentry_sdk(patch):
    return patch("report.sentry.sentry_sdk")


@pytest.fixture(autouse=True)
def get_version(patch):
    return patch("report.sentry.get_version")
