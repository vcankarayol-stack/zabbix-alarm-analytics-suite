WITH current_department AS (
    SELECT
        hostid,
        MAX(value) AS department
    FROM host_tag
    WHERE LOWER(tag) = 'department'
      AND value IS NOT NULL
      AND value <> ''
    GROUP BY hostid
),
alarm_events AS (
    SELECT DISTINCT ON (e.eventid)
        e.eventid,
        cd.department,
        t.priority,
        ROUND((COALESCE(r.clock, extract(epoch from now())) - e.clock) / 60.0, 0) AS duration_minutes
    FROM events e
    JOIN triggers t ON e.objectid = t.triggerid
    JOIN functions f ON t.triggerid = f.triggerid
    JOIN items i ON f.itemid = i.itemid
    JOIN hosts h ON i.hostid = h.hostid
    JOIN current_department cd ON h.hostid = cd.hostid
    LEFT JOIN event_recovery er ON er.eventid = e.eventid
    LEFT JOIN events r ON er.r_eventid = r.eventid
    WHERE e.source = 0
      AND e.object = 0
      AND e.value = 1
      AND t.priority IN (4,5)
      AND t.status = 0
      AND h.status = 0
      AND t.description NOT ILIKE '%Zabbix agent%'
      AND e.clock >= extract(epoch from date_trunc('month', timezone('UTC', now())))
),
department_stats AS (
    SELECT
        department,
        COUNT(*) FILTER (WHERE priority = 4)::numeric AS total_high_alarm,
        COUNT(*) FILTER (WHERE priority = 4 AND duration_minutes >= 240)::numeric AS high_sla_violation,
        CASE
            WHEN COUNT(*) FILTER (WHERE priority = 4) = 0 THEN 100::numeric
            ELSE ROUND(
                (
                    COUNT(*) FILTER (WHERE priority = 4)
                    -
                    COUNT(*) FILTER (WHERE priority = 4 AND duration_minutes >= 240)
                ) * 100.0
                / COUNT(*) FILTER (WHERE priority = 4),
                2
            )
        END AS high_sla_percent,
        COUNT(*) FILTER (WHERE priority = 5)::numeric AS total_disaster_alarm,
        COUNT(*) FILTER (WHERE priority = 5 AND duration_minutes >= 120)::numeric AS disaster_sla_violation,
        CASE
            WHEN COUNT(*) FILTER (WHERE priority = 5) = 0 THEN 100::numeric
            ELSE ROUND(
                (
                    COUNT(*) FILTER (WHERE priority = 5)
                    -
                    COUNT(*) FILTER (WHERE priority = 5 AND duration_minutes >= 120)
                ) * 100.0
                / COUNT(*) FILTER (WHERE priority = 5),
                2
            )
        END AS disaster_sla_percent
    FROM alarm_events
    GROUP BY department
),
final_result AS (
    SELECT
        department,
        total_high_alarm,
        high_sla_violation,
        high_sla_percent,
        total_disaster_alarm,
        disaster_sla_violation,
        disaster_sla_percent
    FROM department_stats

    UNION ALL

    SELECT
        'TOTAL' AS department,
        SUM(total_high_alarm),
        SUM(high_sla_violation),
        CASE
            WHEN SUM(total_high_alarm) = 0 THEN 100::numeric
            ELSE ROUND(
                (SUM(total_high_alarm) - SUM(high_sla_violation))
                * 100.0 / SUM(total_high_alarm),
                2
            )
        END AS high_sla_percent,
        SUM(total_disaster_alarm),
        SUM(disaster_sla_violation),
        CASE
            WHEN SUM(total_disaster_alarm) = 0 THEN 100::numeric
            ELSE ROUND(
                (SUM(total_disaster_alarm) - SUM(disaster_sla_violation))
                * 100.0 / SUM(total_disaster_alarm),
                2
            )
        END AS disaster_sla_percent
    FROM department_stats
)
SELECT *
FROM final_result
ORDER BY
    CASE WHEN department = 'TOTAL' THEN 1 ELSE 0 END,
    high_sla_percent ASC,
    disaster_sla_percent ASC;
