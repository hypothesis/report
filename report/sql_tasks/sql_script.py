import os
import os.path
import textwrap
from dataclasses import dataclass, field
from typing import List

import jinja2
import sqlparse

from report.sql_tasks.sql_query import SQLQuery
from report.sql_tasks.timer import Timer


@dataclass
class SQLScript:
    """A class representing an SQL file with multiple queries."""

    path: str
    """Full path of the script."""

    template_vars: dict
    """Template vars to pass to templated SQL statements."""

    queries: List[SQLQuery] = None
    """Queries contained in this file."""

    timing: Timer = field(default_factory=Timer)
    """Timer for query execution."""

    _jinja_env = jinja2.Environment(undefined=jinja2.StrictUndefined)

    def __post_init__(self):
        if not self.queries:
            self.queries = self._parse()

    def execute(self, connection):
        with self.timing.time_it():
            for query in self.queries:
                query.execute(connection)
                yield query

        yield self

    def dump(self, indent=""):
        """
        Get a string representation of this script.

        :param indent: Optional indenting string prepended to each line.
        """

        return textwrap.indent(
            f"SQL script: '{self.path}'\nDone in: {self.timing.duration}", indent
        )

    @classmethod
    def from_dir(cls, task_dir: str, template_vars: dict):
        """
        Generate `SQLFile` objects from files found in a directory.

        This will return a generator of `SQLFile` based on the natural sorting
        order of files found in the directory, and subdirectories. Only files
        with a `.sql` prefix are considered. Files with `.jinja2.sql` are
        treated as Jinja2 templated SQL and are rendered using the provided
        environment.

        :param task_dir: The directory to read from
        :param template_vars: Variables to include in Jinja2 SQL files

        :raises NotADirectoryError: if `task_dir` is not a directory
        """
        if not os.path.isdir(task_dir):
            raise NotADirectoryError(f"Cannot find the task directory: '{task_dir}'")

        for item in sorted(os.listdir(task_dir)):
            full_name = os.path.join(task_dir, item)

            if os.path.isdir(full_name):
                yield from cls.from_dir(full_name, template_vars=template_vars)

            elif full_name.endswith(".sql"):
                yield SQLScript(full_name, template_vars=template_vars)

    def _parse(self):
        with open(self.path, encoding="utf-8") as handle:
            script_text = handle.read()

        if self.path.endswith("jinja2.sql"):
            # Looks like this file has been templated
            script_text = self._jinja_env.from_string(script_text).render(
                self.template_vars
            )

        return [
            SQLQuery(text=query, index=index)
            for index, query in (enumerate(sqlparse.split(script_text)))
        ]
