# Dashboard variables

The Alarm Investigation Dashboard uses cascading variables:

```text
Department → Team → Host
```

The default Zabbix host tag names are:

| Variable | Zabbix host tag |
|---|---|
| Department | `department` |
| Team | `team` |

If your Zabbix environment uses different tag names, update the SQL queries inside the dashboard variables and panels.

## Example

If your host tag is `business_unit` instead of `team`, replace:

```sql
LOWER(ht.tag) = 'team'
```

with:

```sql
LOWER(ht.tag) = 'business_unit'
```
