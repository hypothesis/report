# pragma: no cover
import os

from pyramid.config import Configurator


def create_app(_config, **settings):  # pragma: no cover
    """Placeholder app to keep compatibilty with pyramid app strucuture"""
    config = Configurator(settings=settings)
    config.add_settings({"sqlalchemy.url": os.environ["DATABASE_URL"]})
    return config.make_wsgi_app()
