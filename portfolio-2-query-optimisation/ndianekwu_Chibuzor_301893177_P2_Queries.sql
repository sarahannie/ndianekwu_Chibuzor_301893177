-- Show related ticket, ticket_order, event records (up to 20).
SELECT t0."ticket_id" AS "ticket_ticket_id",
       t0."seat_label" AS "ticket_seat_label",
       t1."order_id" AS "ticket_order_order_id",
       t1."customer_email" AS "ticket_order_customer_email",
       t2."event_id" AS "event_event_id",
       t2."title" AS "event_title"
FROM portfolio."ticket" t0
JOIN portfolio."ticket_order" t1 ON t0."order_id" = t1."order_id"
JOIN portfolio."event" t2 ON t0."event_id" = t2."event_id"
ORDER BY t0."ticket_id", t1."order_id", t2."event_id"
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT t0."ticket_id" AS "ticket_ticket_id",
       t0."seat_label" AS "ticket_seat_label",
       t1."order_id" AS "ticket_order_order_id",
       t1."customer_email" AS "ticket_order_customer_email",
       t2."event_id" AS "event_event_id",
       t2."title" AS "event_title"
FROM portfolio."ticket" t0
JOIN portfolio."ticket_order" t1 ON t0."order_id" = t1."order_id"
JOIN portfolio."event" t2 ON t0."event_id" = t2."event_id"
ORDER BY t0."ticket_id", t1."order_id", t2."event_id"
LIMIT 20;

-- Find event records where venue_id matches 100 (up to 20).
SELECT * FROM portfolio."event"
WHERE "venue_id" IS NOT DISTINCT FROM 100
ORDER BY "event_id"
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM portfolio."event"
WHERE "venue_id" IS NOT DISTINCT FROM 100
ORDER BY "event_id"
LIMIT 20;

-- Count ticket records for each order_id (up to 20 groups).
SELECT "order_id", count(*) AS record_count
FROM portfolio."ticket"
GROUP BY "order_id"
ORDER BY record_count DESC, "order_id" NULLS LAST
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT "order_id", count(*) AS record_count
FROM portfolio."ticket"
GROUP BY "order_id"
ORDER BY record_count DESC, "order_id" NULLS LAST
LIMIT 20;
