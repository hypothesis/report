import os

import pytest

from report import db

TEST_SETTINGS = {
    "sqlalchemy.url": os.environ.get(
        "TEST_DATABASE_URL", "postgresql://postgres@localhost:5436/report_unittests"
    ),
}


@pytest.fixture(scope="session")
def db_engine():
    db_engine = db.make_engine(TEST_SETTINGS)
    yield db_engine

    db_engine.dispose()
