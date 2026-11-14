-- Every statement below is deliberately invalid and should be rejected.
-- Run with:  psql -d <database> -f this_file.sql   (do not use ON_ERROR_STOP)
\set VERBOSITY verbose
SET search_path TO portfolio;

\echo '--- row counts before the tests'
SELECT (SELECT count(*) FROM customer) AS customer, (SELECT count(*) FROM venue) AS venue,
       (SELECT count(*) FROM event) AS event, (SELECT count(*) FROM ticket_order) AS ticket_order,
       (SELECT count(*) FROM ticket) AS ticket;

\echo '--- 1. duplicate primary key (venue 100 exists)'
INSERT INTO venue (venue_id, name, city, capacity) VALUES (100, 'Copy Hall', 'Lagos', 100);

\echo '--- 2. duplicate customer email'
INSERT INTO customer (customer_id, full_name, email) VALUES (50, 'Second Adaeze', 'adaeze.okonkwo@example.test');

\echo '--- 3. event for a venue that does not exist'
INSERT INTO event (event_id, venue_id, title, starts_at, capacity) VALUES (250, 999, 'Nowhere Show', '2026-12-30T19:00:00+01', 100);

\echo '--- 4. order for a customer that does not exist'
INSERT INTO ticket_order (order_id, customer_id, placed_at) VALUES (390, 999, '2026-11-14T10:00:00+01');

\echo '--- 5. ticket for an order that does not exist'
INSERT INTO ticket (ticket_id, order_id, event_id, price, issued_at) VALUES (490, 999, 200, 15000, '2026-11-14T10:00:00+01');

\echo '--- 6. ticket for an event that does not exist'
INSERT INTO ticket (ticket_id, order_id, event_id, price, issued_at) VALUES (491, 300, 999, 15000, '2026-11-14T10:00:00+01');

\echo '--- 7. venue with zero capacity'
INSERT INTO venue (venue_id, name, city, capacity) VALUES (150, 'Empty Room', 'Lagos', 0);

\echo '--- 8. event with negative capacity'
INSERT INTO event (event_id, venue_id, title, starts_at, capacity) VALUES (251, 100, 'Minus Show', '2026-12-30T19:00:00+01', -5);

\echo '--- 9. free ticket (price must be above zero)'
INSERT INTO ticket (ticket_id, order_id, event_id, price, issued_at) VALUES (492, 300, 200, 0, '2026-11-14T10:00:00+01');

\echo '--- 10. seat A1 at event 200 is already sold'
INSERT INTO ticket (ticket_id, order_id, event_id, seat_label, price, issued_at) VALUES (493, 301, 200, 'A1', 15000, '2026-11-14T10:00:00+01');

\echo '--- 11. event status outside the allowed list'
INSERT INTO event (event_id, venue_id, title, starts_at, status, capacity) VALUES (252, 100, 'Maybe Show', '2026-12-30T19:00:00+01', 'postponed', 100);

\echo '--- 12. payment status outside the allowed list'
INSERT INTO ticket_order (order_id, customer_id, placed_at, payment_status) VALUES (391, 1, '2026-11-14T10:00:00+01', 'unknown');

\echo '--- 13. ticket status outside the allowed list'
INSERT INTO ticket (ticket_id, order_id, event_id, price, status, issued_at) VALUES (494, 300, 200, 15000, 'lost', '2026-11-14T10:00:00+01');

\echo '--- 14. venue without a name'
INSERT INTO venue (venue_id, name, city, capacity) VALUES (151, NULL, 'Lagos', 100);

\echo '--- 15. deleting a venue that still has events'
DELETE FROM venue WHERE venue_id = 100;

\echo '--- allowed: two general admission tickets (NULL seat) for the same event'
BEGIN;
INSERT INTO ticket (ticket_id, order_id, event_id, price, issued_at) VALUES (495, 302, 202, 25000, '2026-11-14T10:00:00+01');
INSERT INTO ticket (ticket_id, order_id, event_id, price, issued_at) VALUES (496, 302, 202, 25000, '2026-11-14T10:00:00+01');
ROLLBACK;

\echo '--- row counts after the tests (should match the first table)'
SELECT (SELECT count(*) FROM customer) AS customer, (SELECT count(*) FROM venue) AS venue,
       (SELECT count(*) FROM event) AS event, (SELECT count(*) FROM ticket_order) AS ticket_order,
       (SELECT count(*) FROM ticket) AS ticket;
