SELECT
    ht.value AS team,
    COUNT(DISTINCT e.eventid) AS alarm_count
FROM events e
JOIN triggers t ON e.objectid = t.triggerid
JOIN functions f ON t.triggerid = f.triggerid
JOIN items i ON f.itemid = i.itemid
JOIN hosts h ON i.hostid = h.hostid
JOIN host_tag ht ON h.hostid = ht.hostid
WHERE e.source = 0
  AND e.object = 0
  AND e.value = 1
  AND t.priority IN (2,3,4,5)
  AND t.status = 0
  AND h.status = 0
  AND LOWER(ht.tag) = 'team'
  AND e.clock >= extract(epoch from date_trunc('month', now()))
GROUP BY ht.value
ORDER BY alarm_count DESC;
