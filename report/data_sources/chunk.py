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


def chunk_with_max_len(items: Iterable[str], chunk_size: int, max_chars: int):
    """Return items in chunks with a maximum size and char length.

    :param items: Items to break into chunks
    :param max_chars: Maximum total char length of a single chunk
    :param chunk_size: The maximum size of a chunk

    :raises ValueError: If `chunk_size` or `max_chars` is not a positive integer
    """
    if chunk_size < 1:
        raise ValueError(f"Invalid chunk size: {chunk_size}")

    if max_chars < 1:
        raise ValueError(f"Invalid max chars: {max_chars}")

    batch, batch_chars = [], 0

    for item in items:
        batch_chars += len(item)
        if batch and batch_chars >= max_chars or len(batch) >= chunk_size:
            yield batch
            batch, batch_chars = [], 0

        batch.append(item)

    if batch:
        yield batch
