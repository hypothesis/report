import pytest

from report.data_sources.chunk import chunk


class TestChunk:
    @pytest.mark.parametrize(
        "items,chunks",
        (
            ([1, 2, 3, 4, 5], [[1, 2], [3, 4], [5]]),
            ([1, 2, 3, 4], [[1, 2], [3, 4]]),
            ([], []),
        ),
    )
    def test_it(self, items, chunks):
        result = chunk(items, chunk_size=2)

        assert [list(item) for item in result] == chunks

    @pytest.mark.parametrize("chunk_size", (0, -1))
    def test_it_rejects_silly_values(self, chunk_size):
        with pytest.raises(ValueError):
            list(chunk([], chunk_size=chunk_size))
