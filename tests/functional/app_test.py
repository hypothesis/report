from report.app import create_app


def test_it():
    assert create_app(None)
