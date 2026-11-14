-- Portfolio 2: does an index on ticket.event_id help the "sales for one event" lookup?
-- The test runs on the real ticket table inside a transaction that is rolled back at the end,
-- so the extra rows and the index do not stay in the database.
SET search_path TO portfolio;
BEGIN;

-- Bulk data: 300 extra events, 3,000 orders, 60,000 general admission tickets.
INSERT INTO event (event_id, venue_id, title, starts_at, capacity)
SELECT 1000 + g, 100 + g % 5, 'Load test event ' || g, timestamptz '2027-01-01' + g * interval '1 day', 500
FROM generate_series(1, 300) AS g;

INSERT INTO ticket_order (order_id, customer_id, placed_at, payment_status)
SELECT 10000 + g, 1 + g % 12, timestamptz '2026-11-01' + g * interval '1 minute', 'paid'
FROM generate_series(1, 3000) AS g;

INSERT INTO ticket (ticket_id, order_id, event_id, price, issued_at)
SELECT 100000 + g, 10000 + 1 + g % 3000, 1000 + 1 + g % 300, 5000 + (g % 4) * 2500,
       timestamptz '2026-11-01' + g * interval '1 minute'
FROM generate_series(1, 60000) AS g;

ANALYZE ticket;
SELECT count(*) AS ticket_rows FROM ticket;

\echo '=== BEFORE the index: result, then three measured runs'
SELECT count(*) AS tickets_sold, sum(price) AS revenue_naira
FROM ticket WHERE event_id = 1042 AND status IN ('issued', 'used');

EXPLAIN (ANALYZE, BUFFERS) SELECT count(*), sum(price) FROM ticket WHERE event_id = 1042 AND status IN ('issued', 'used');
EXPLAIN (ANALYZE, BUFFERS) SELECT count(*), sum(price) FROM ticket WHERE event_id = 1042 AND status IN ('issued', 'used');
EXPLAIN (ANALYZE, BUFFERS) SELECT count(*), sum(price) FROM ticket WHERE event_id = 1042 AND status IN ('issued', 'used');

CREATE INDEX idx_ticket_event ON ticket (event_id);
ANALYZE ticket;

\echo '=== AFTER the index: same query, same result, three measured runs'
SELECT count(*) AS tickets_sold, sum(price) AS revenue_naira
FROM ticket WHERE event_id = 1042 AND status IN ('issued', 'used');

EXPLAIN (ANALYZE, BUFFERS) SELECT count(*), sum(price) FROM ticket WHERE event_id = 1042 AND status IN ('issued', 'used');
EXPLAIN (ANALYZE, BUFFERS) SELECT count(*), sum(price) FROM ticket WHERE event_id = 1042 AND status IN ('issued', 'used');
EXPLAIN (ANALYZE, BUFFERS) SELECT count(*), sum(price) FROM ticket WHERE event_id = 1042 AND status IN ('issued', 'used');

\echo '=== A query the index does not help: most rows match, so the planner keeps the sequential scan'
EXPLAIN (ANALYZE, BUFFERS) SELECT count(*) FROM ticket WHERE event_id > 1010;

\echo '=== Size of the new index'
SELECT pg_size_pretty(pg_relation_size('idx_ticket_event')) AS index_size,
       pg_size_pretty(pg_relation_size('ticket'))           AS table_size;

ROLLBACK;

-- Keep the index for normal use (the small sample table will still be scanned directly).
CREATE INDEX idx_ticket_event ON ticket (event_id);
