WITH short_events AS (
    SELECT DISTINCT ON (e.eventid)
        e.eventid,
        h.name AS host_name,
        CASE t.priority
            WHEN 2 THEN 'Warning'
            WHEN 3 THEN 'Average'
            WHEN 4 THEN 'High'
            WHEN 5 THEN 'Disaster'
        END AS severity,
        t.description AS trigger_name,
        e.clock AS problem_clock,
        r.clock AS recovery_clock,
        ROUND((r.clock - e.clock) / 60.0, 1) AS duration_minutes
    FROM event_recovery er
    JOIN events e ON er.eventid = e.eventid
    JOIN events r ON er.r_eventid = r.eventid
    JOIN triggers t ON e.objectid = t.triggerid
    JOIN functions f ON t.triggerid = f.triggerid
    JOIN items i ON f.itemid = i.itemid
    JOIN hosts h ON i.hostid = h.hostid
    WHERE e.source = 0
      AND e.object = 0
      AND e.value = 1
      AND t.priority IN (2,3,4,5)
      AND t.status = 0
      AND h.status = 0
      AND e.clock >= extract(epoch from date_trunc('month', now()))
      AND (r.clock - e.clock) <= 300
)
SELECT
    host_name,
    severity,
    trigger_name,
    COUNT(*) AS short_alarm_count,
    ROUND(AVG(duration_minutes), 1) AS avg_duration_minutes,
    to_char(to_timestamp(MAX(problem_clock)), 'YYYY-MM-DD HH24:MI:SS') AS last_problem_time
FROM short_events
GROUP BY host_name, severity, trigger_name
HAVING COUNT(*) >= 5
ORDER BY short_alarm_count DESC, avg_duration_minutes ASC;
