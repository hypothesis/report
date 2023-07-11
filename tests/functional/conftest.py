import contextlib
import os

import pytest
from sqlalchemy.orm import sessionmaker

from report import db

TEST_SETTINGS = {"database_url": os.environ["DATABASE_URL"]}

TEST_ENVIRONMENT = {"DATABASE_URL": TEST_SETTINGS["database_url"]}


@pytest.fixture
def with_clean_db(db_engine):
    with contextlib.closing(db_engine.connect()) as conn:
        tx = conn.begin()
        conn.execute("DROP SCHEMA IF EXISTS report CASCADE;")
        tx.commit()


@pytest.fixture
def db_session(db_engine):
    """Get a standalone database session for preparing database state."""
    Session = sessionmaker()
    session = Session(bind=db_engine)
    yield session
    session.close()


@pytest.fixture(scope="session")
def db_engine():
    db_engine = db.make_engine(TEST_SETTINGS)
    yield db_engine

    db_engine.dispose()
