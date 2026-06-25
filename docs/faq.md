# FAQ

## Does this require the Zabbix API?

No. The dashboards use SQL queries against the Zabbix PostgreSQL database.

## Does this support MySQL or MariaDB?

Not in v1.0.0. The dashboards are prepared for PostgreSQL.

## Can I change SLA thresholds?

Yes. SLA thresholds are defined inside the SQL queries.

## Can I use different host tag names?

Yes. Update the variable SQL queries and panel SQL filters.

## Should I use a read-only DB user?

Yes. Always use a read-only PostgreSQL user for Grafana.
