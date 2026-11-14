-- Portfolio 2: queries for the operations listed in the case study.
-- Run after the Portfolio 1 schema and sample data.
SET search_path TO portfolio;

\echo '=== Q1. Events at one venue inside a date window (find events by venue and start time)'
SELECT e.event_id, e.title, e.starts_at, e.status
FROM event e
WHERE e.venue_id = 101
  AND e.starts_at >= '2026-12-01' AND e.starts_at < '2027-01-01'
ORDER BY e.starts_at;

EXPLAIN (ANALYZE, BUFFERS)
SELECT e.event_id, e.title, e.starts_at, e.status
FROM event e
WHERE e.venue_id = 101
  AND e.starts_at >= '2026-12-01' AND e.starts_at < '2027-01-01'
ORDER BY e.starts_at;

\echo '=== Q2. Issued tickets and revenue per event (cancelled tickets do not count)'
SELECT e.event_id, e.title,
       count(t.ticket_id)        AS tickets_sold,
       coalesce(sum(t.price), 0) AS revenue_naira
FROM event e
LEFT JOIN ticket t ON t.event_id = e.event_id AND t.status IN ('issued', 'used')
GROUP BY e.event_id, e.title
ORDER BY revenue_naira DESC, e.event_id;

EXPLAIN (ANALYZE, BUFFERS)
SELECT e.event_id, e.title,
       count(t.ticket_id)        AS tickets_sold,
       coalesce(sum(t.price), 0) AS revenue_naira
FROM event e
LEFT JOIN ticket t ON t.event_id = e.event_id AND t.status IN ('issued', 'used')
GROUP BY e.event_id, e.title
ORDER BY revenue_naira DESC, e.event_id;

\echo '=== Q3. Order history for one customer (four-table join)'
SELECT c.full_name, o.order_id, o.placed_at, o.payment_status,
       e.title, v.name AS venue, t.seat_label, t.price
FROM customer c
JOIN ticket_order o ON o.customer_id = c.customer_id
JOIN ticket t       ON t.order_id = o.order_id
JOIN event e        ON e.event_id = t.event_id
JOIN venue v        ON v.venue_id = e.venue_id
WHERE c.email = 'adaeze.okonkwo@example.test'
ORDER BY o.placed_at, t.ticket_id;

EXPLAIN (ANALYZE, BUFFERS)
SELECT c.full_name, o.order_id, o.placed_at, o.payment_status,
       e.title, v.name AS venue, t.seat_label, t.price
FROM customer c
JOIN ticket_order o ON o.customer_id = c.customer_id
JOIN ticket t       ON t.order_id = o.order_id
JOIN event e        ON e.event_id = t.event_id
JOIN venue v        ON v.venue_id = e.venue_id
WHERE c.email = 'adaeze.okonkwo@example.test'
ORDER BY o.placed_at, t.ticket_id;

\echo '=== Q4. Scheduled events that are at least half sold (HAVING on an aggregate)'
SELECT e.event_id, e.title, e.capacity,
       count(t.ticket_id) AS sold,
       round(100.0 * count(t.ticket_id) / e.capacity, 1) AS percent_sold
FROM event e
JOIN ticket t ON t.event_id = e.event_id AND t.status IN ('issued', 'used')
WHERE e.status = 'scheduled'
GROUP BY e.event_id, e.title, e.capacity
HAVING count(t.ticket_id) >= e.capacity / 2.0
ORDER BY percent_sold DESC;
