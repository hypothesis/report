import pytest

from report.data_sources.chunk import chunk, chunk_with_max_len


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


class TestChunkWithMaxLen:
    @pytest.mark.parametrize(
        "items,chunks",
        (
            (["1", "2", "3", "4", "5"], [["1", "2"], ["3", "4"], ["5"]]),
            (["1", "2", "3", "4"], [["1", "2"], ["3", "4"]]),
            ([], []),
        ),
    )
    def test_it(self, items, chunks):
        result = chunk_with_max_len(items, chunk_size=2, max_chars=10)

        assert [list(item) for item in result] == chunks

    def test_it_with_long_items(self):
        result = chunk_with_max_len(
            ["12345", "a", "abcdefghij"], chunk_size=10, max_chars=5
        )

        assert [list(item) for item in result] == [["12345"], ["a"], ["abcdefghij"]]

    @pytest.mark.parametrize("chunk_size", (0, -1))
    def test_it_rejects_silly_chunk_size_values(self, chunk_size):
        with pytest.raises(ValueError):
            list(chunk_with_max_len([], max_chars=1, chunk_size=chunk_size))

    @pytest.mark.parametrize("max_chars", (0, -1))
    def test_it_rejects_silly_max_chars_values(self, max_chars):
        with pytest.raises(ValueError):
            list(chunk_with_max_len([], max_chars=max_chars, chunk_size=1))
