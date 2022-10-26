from webtest import TestApp

from report.app import create_app


def test_it():
    app = TestApp(create_app({}))

    response = app.get("/")

    assert response.json == {"Hello": "Pyramid!"}
