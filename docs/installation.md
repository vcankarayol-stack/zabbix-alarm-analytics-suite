# Installation

## Prerequisites

- Grafana 11.x or later
- Zabbix 7.x or later
- PostgreSQL datasource plugin enabled in Grafana
- Read-only PostgreSQL access to the Zabbix database

## Import a dashboard

1. Open Grafana.
2. Go to **Dashboards → New → Import**.
3. Upload one of the JSON files from `dashboards/`.
4. Select your PostgreSQL datasource connected to the Zabbix database.
5. Click **Import**.
6. Validate the dashboard variables.

## Recommended datasource permissions

Use a read-only PostgreSQL user. Do not connect Grafana using a privileged database account.
