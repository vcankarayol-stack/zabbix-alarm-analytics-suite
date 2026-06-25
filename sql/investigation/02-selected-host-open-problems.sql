SELECT DISTINCT ON (e.eventid)
    CASE t.priority
        WHEN 1 THEN 'Information'
        WHEN 2 THEN 'Warning'
        WHEN 3 THEN 'Average'
        WHEN 4 THEN 'High'
        WHEN 5 THEN 'Disaster'
    END AS severity,

    e.name AS problem_name,

    to_char(
        timezone('UTC', to_timestamp(e.clock)),
        'YYYY-MM-DD HH24:MI:SS'
    ) AS problem_time,

    ROUND(
        (extract(epoch from now()) - e.clock) / 60.0,
        0
    ) AS open_minutes

FROM events e
JOIN triggers t ON e.objectid = t.triggerid
JOIN functions f ON t.triggerid = f.triggerid
JOIN items i ON f.itemid = i.itemid
JOIN hosts h ON i.hostid = h.hostid
LEFT JOIN event_recovery er ON er.eventid = e.eventid

WHERE e.source = 0
  AND e.object = 0
  AND e.value = 1
  AND er.r_eventid IS NULL
  AND t.status = 0
  AND h.status = 0
  AND h.host = '$Host'

ORDER BY
    e.eventid,
    t.priority DESC,
    open_minutes DESC;
