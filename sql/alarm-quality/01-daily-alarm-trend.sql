SELECT
    date_trunc('day', to_timestamp(e.clock)) AS time,
    COUNT(DISTINCT e.eventid) AS alarm_count
FROM events e
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
GROUP BY 1
ORDER BY 1;
