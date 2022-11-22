import sqlalchemy
from sqlalchemy.orm import sessionmaker

SESSION = sessionmaker()


def make_engine(settings):  # pragma: no cover
    """Construct a sqlalchemy engine from the passed ``settings``."""
    return sqlalchemy.create_engine(settings["database_url"])
