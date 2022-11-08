import functools
import os
from unittest import mock

import pytest

from report import db

TEST_SETTINGS = {
    "database_url": os.environ.get(
        "TEST_DATABASE_URL", "postgresql://postgres@localhost:5436/report_unittests"
    ),
}


def _autopatcher(request, target, **kwargs):
    """Patch and cleanup automatically. Wraps :py:func:`mock.patch`."""
    options = {"autospec": True}
    options.update(kwargs)
    patcher = mock.patch(target, **options)

    obj = patcher.start()

    request.addfinalizer(patcher.stop)
    return obj


@pytest.fixture
def patch(request):
    return functools.partial(_autopatcher, request)


@pytest.fixture(scope="session")
def db_engine():
    db_engine = db.make_engine(TEST_SETTINGS)
    yield db_engine

    db_engine.dispose()
