WITH resolved_events AS (
    SELECT DISTINCT ON (e.eventid)
        e.eventid,
        t.priority,
        (r.clock - e.clock) / 60.0 AS duration_minutes
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
)
SELECT
    CASE priority
        WHEN 2 THEN 'Warning'
        WHEN 3 THEN 'Average'
        WHEN 4 THEN 'High'
        WHEN 5 THEN 'Disaster'
    END AS severity,
    COUNT(*) AS resolved_alarm_count,
    ROUND(AVG(duration_minutes), 0) AS avg_duration_minutes,
    ROUND(MAX(duration_minutes), 0) AS max_duration_minutes
FROM resolved_events
GROUP BY priority
ORDER BY priority;
