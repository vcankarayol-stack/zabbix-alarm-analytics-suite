WITH disaster_events AS (
    SELECT DISTINCT ON (e.eventid)
        e.eventid,
        'Disaster' AS severity,
        COALESCE(ht.value, 'No Team') AS team,
        h.name AS host_name,
        e.name AS problem_name,
        e.clock AS problem_clock,
        r.clock AS recovery_clock,
        ROUND((r.clock - e.clock) / 60.0, 0) AS duration_minutes,
        ROUND((r.clock - e.clock) / 3600.0, 1) AS duration_hours,
        120 AS sla_limit_minutes
    FROM event_recovery er
    JOIN events e ON er.eventid = e.eventid
    JOIN events r ON er.r_eventid = r.eventid
    JOIN triggers t ON e.objectid = t.triggerid
    JOIN functions f ON t.triggerid = f.triggerid
    JOIN items i ON f.itemid = i.itemid
    JOIN hosts h ON i.hostid = h.hostid
    LEFT JOIN host_tag ht 
        ON h.hostid = ht.hostid 
       AND LOWER(ht.tag) = 'team'
    WHERE e.source = 0
      AND e.object = 0
      AND e.value = 1
      AND t.priority = 5
      AND t.status = 0
      AND h.status = 0
      AND e.clock >= extract(epoch from date_trunc('month', timezone('UTC', now())))
)
SELECT
    severity,
    team,
    host_name,
    problem_name,
    to_char(timezone('UTC', to_timestamp(problem_clock)), 'YYYY-MM-DD HH24:MI:SS') AS problem_time,
    to_char(timezone('UTC', to_timestamp(recovery_clock)), 'YYYY-MM-DD HH24:MI:SS') AS recovery_time,
    duration_minutes,
    duration_hours,
    sla_limit_minutes,
    duration_minutes - sla_limit_minutes AS exceeded_minutes
FROM disaster_events
WHERE duration_minutes > 120
ORDER BY exceeded_minutes DESC;
