SELECT DISTINCT ON (e.eventid)
    CASE t.priority
        WHEN 4 THEN 'High'
        WHEN 5 THEN 'Disaster'
    END AS severity,

    e.name AS problem_name,

    to_char(timezone('UTC', to_timestamp(e.clock)), 'YYYY-MM-DD HH24:MI:SS') AS problem_time,
    to_char(timezone('UTC', to_timestamp(r.clock)), 'YYYY-MM-DD HH24:MI:SS') AS recovery_time,

    ROUND((r.clock - e.clock) / 60.0, 0) AS duration_minutes,

    CASE
        WHEN t.priority = 4 THEN 240
        WHEN t.priority = 5 THEN 120
    END AS sla_limit_minutes,

    ROUND((r.clock - e.clock) / 60.0, 0) -
    CASE
        WHEN t.priority = 4 THEN 240
        WHEN t.priority = 5 THEN 120
    END AS exceeded_minutes

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
  AND t.priority IN (4,5)
  AND t.status = 0
  AND h.status = 0
  AND h.host = '$Host'
  AND e.clock BETWEEN $__unixEpochFrom() AND $__unixEpochTo()
  AND (
        (t.priority = 4 AND (r.clock - e.clock) / 60.0 > 240)
        OR
        (t.priority = 5 AND (r.clock - e.clock) / 60.0 > 120)
      )

ORDER BY
    e.eventid,
    exceeded_minutes DESC;
