from unittest.mock import sentinel

import pytest

from report.sentry import load_sentry


class TestLoadSentry:
    def test_it(self, os, sentry_sdk):
        os.environ = {"SENTRY_DSN": sentinel.sentry_dsn}

        load_sentry()

        sentry_sdk.init.assert_called_once_with(dsn=sentinel.sentry_dsn)

    def test_it_with_no_sentry_dsn(self, os, sentry_sdk):
        os.environ = {}

        load_sentry()

        sentry_sdk.init.assert_not_called()

    @pytest.fixture
    def os(self, patch):
        return patch("report.sentry.os")

    @pytest.fixture
    def sentry_sdk(self, patch):
        return patch("report.sentry.sentry_sdk")
