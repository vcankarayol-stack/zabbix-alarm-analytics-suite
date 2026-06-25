# Customization

## SLA thresholds

Default thresholds:

- High: 240 minutes
- Disaster: 120 minutes

Search the SQL queries for these values and adjust them to match your operational SLA policy.

## Severity scope

Some analytics panels exclude `Information` and `Not classified` severities. You can include or exclude severities by changing `t.priority IN (...)` filters.

## Time range

The Alarm Quality Dashboard is designed for current-month analytics. The Alarm Investigation Dashboard uses the Grafana time picker for host-level investigation.
