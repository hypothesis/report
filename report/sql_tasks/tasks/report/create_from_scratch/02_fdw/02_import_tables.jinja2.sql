{% set lms_fdw_tables = [
    ("public", "organization"), 
    ("report", "organization_activity"), 

   ]
%}

{% for schema, table_name in lms_fdw_tables %}
IMPORT FOREIGN SCHEMA "{{schema}}" LIMIT TO (
    "{{table_name}}"
) FROM SERVER "lms_us_server" INTO lms_us;
IMPORT FOREIGN SCHEMA "{{schema}}" LIMIT TO (
    "{{table_name}}"
) FROM SERVER "lms_ca_server" INTO lms_ca;
{% endfor %}
