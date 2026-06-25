SELECT
    to_char(timezone('UTC', to_timestamp(e.clock)), 'YYYY-MM-DD HH24:MI:SS') AS problem_time,
    CASE t.priority
        WHEN 1 THEN 'Information'
        WHEN 2 THEN 'Warning'
        WHEN 3 THEN 'Average'
        WHEN 4 THEN 'High'
        WHEN 5 THEN 'Disaster'
    END AS severity,
    e.name AS problem_name
FROM events e
JOIN triggers t ON e.objectid = t.triggerid
JOIN functions f ON e.objectid = f.triggerid
JOIN items i ON f.itemid = i.itemid
JOIN hosts h ON i.hostid = h.hostid
WHERE e.source = 0
  AND e.object = 0
  AND e.value = 1
  AND t.priority IN (1,2,3,4,5)
  AND h.status = 0
  AND h.host = '$Host'
  AND e.clock BETWEEN $__unixEpochFrom() AND $__unixEpochTo()
GROUP BY e.eventid, e.clock, t.priority, e.name
ORDER BY e.clock DESC
LIMIT 50;
