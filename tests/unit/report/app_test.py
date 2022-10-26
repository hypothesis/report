from report.app import report


def test_report():
    assert report() == 42
