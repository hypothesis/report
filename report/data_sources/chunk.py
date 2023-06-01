from itertools import islice
from typing import Iterable


def chunk(items: Iterable, chunk_size: int):
    """Return items in multiple chunks of a maximum size.

    :param items: Items to break into chunks
    :param chunk_size: The maximum size of a chunk (last may be shorter)

    :raises ValueError: If `chunk_size` is not a positive integer
    """
    if chunk_size < 1:
        raise ValueError(f"Invalid chunk size: {chunk_size}")

    # Create an iterable we can consume from
    iter_items = iter(items)
    # Use the two-argument form of iter to specify when to stop. This will
    # cause iter to call the lambda until it returns an empty tuple, which
    # should consume the iterable above.
    return iter(lambda: tuple(islice(iter_items, chunk_size)), ())
