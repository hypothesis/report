import re
import textwrap
from dataclasses import dataclass, field
from typing import Optional

import sqlalchemy as sa
from sqlalchemy.engine import Connection
from tabulate import tabulate

from report.sql_tasks.timer import Timer


@dataclass
class SQLQuery:
    """A class representing an individual SQL query."""

    index: int
    """Index of this query inside the script."""

    text: str
    """Text of the query."""

    columns: Optional[list] = None
    """Columns of the returned values (if any)."""

    rows: Optional[list] = None
    """Rows of the returned values (if any)."""

    timing: Timer = field(default_factory=Timer)
    """Timer for query execution."""

    def execute(self, connection: Connection, parameters=None):
        """Execute this query in the given session."""

        with self.timing.time_it():
            if not parameters:
                parameters = {}

            cursor = connection.execute(sa.text(self.text), **parameters)
            if cursor.returns_rows:
                self.columns = [col.name for col in cursor.cursor.description]
                self.rows = cursor.fetchall()

    def dump(self, indent=""):
        """
        Get a string representation of this query like psql's format.

        :param indent: Optional indenting string prepended to each line.
        """

        text = textwrap.indent(self._clean_query(self.text), prefix=f"{self.index}=> ")
        if self.rows:
            text += "\n" + tabulate(
                tabular_data=[list(row) for row in self.rows],
                headers=self.columns,
                tablefmt="psql",
            )
        text += f"\n\nTime: {self.timing.duration}"
        return textwrap.indent(text, indent)

    @staticmethod
    def _clean_query(query: str) -> str:
        """Clean any of the query's lines marked as sensitive."""
        return "\n".join(
            [
                re.sub(r"[^\s]", "*", line) if "secret" in line.lower() else line
                for line in query.split("\n")
            ]
        )
