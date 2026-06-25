SELECT
    h.name AS host_name,
    COUNT(DISTINCT e.eventid) AS alarm_count,
    COUNT(DISTINCT t.triggerid) AS trigger_count,
    to_char(timezone('UTC', to_timestamp(MAX(e.clock))), 'YYYY-MM-DD HH24:MI:SS') AS last_alarm_time
FROM events e
JOIN triggers t ON e.objectid = t.triggerid
JOIN functions f ON t.triggerid = f.triggerid
JOIN items i ON f.itemid = i.itemid
JOIN hosts h ON i.hostid = h.hostid
WHERE e.source = 0
  AND e.object = 0
  AND e.value = 1
  AND t.priority IN (2,3,4,5)
  AND h.status = 0
  AND t.status = 0
  AND e.clock >= extract(epoch from date_trunc('month', timezone('UTC', now())))
GROUP BY h.name
ORDER BY alarm_count DESC
LIMIT 20;
