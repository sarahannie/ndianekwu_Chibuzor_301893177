-- Portfolio 3, part 1: COMMIT and ROLLBACK on a real ticket order (one session).
-- Run after the Portfolio 1 schema and sample data:  psql -d <database> -f this_file.sql
\set VERBOSITY verbose
SET search_path TO portfolio;

\echo '=== 1. COMMIT: an order and its two seats are saved together'
BEGIN;
INSERT INTO ticket_order (order_id, customer_id, placed_at, payment_status)
VALUES (350, 4, now(), 'paid');
INSERT INTO ticket (ticket_id, order_id, event_id, seat_label, price, issued_at)
VALUES (450, 350, 203, 'B1', 12000, now()),
       (451, 350, 203, 'B2', 12000, now());
COMMIT;

SELECT o.order_id, o.payment_status, t.ticket_id, t.seat_label
FROM ticket_order o JOIN ticket t ON t.order_id = o.order_id
WHERE o.order_id = 350 ORDER BY t.ticket_id;

\echo '=== 2. ROLLBACK: seat A1 at event 200 is already sold, so the whole order must go'
BEGIN;
INSERT INTO ticket_order (order_id, customer_id, placed_at, payment_status)
VALUES (351, 5, now(), 'paid');
INSERT INTO ticket (ticket_id, order_id, event_id, seat_label, price, issued_at)
VALUES (452, 351, 200, 'B5', 15000, now());
-- this one breaks ticket_seat_unique
INSERT INTO ticket (ticket_id, order_id, event_id, seat_label, price, issued_at)
VALUES (453, 351, 200, 'A1', 15000, now());
-- after an error PostgreSQL refuses further statements in the same transaction
SELECT count(*) FROM ticket;
ROLLBACK;

\echo '--- order 351 and ticket 452 should both be missing (0 rows each)'
SELECT order_id FROM ticket_order WHERE order_id = 351;
SELECT ticket_id FROM ticket WHERE ticket_id IN (452, 453);

\echo '=== 3. SAVEPOINT: keep the order, undo only the failed seat'
BEGIN;
INSERT INTO ticket_order (order_id, customer_id, placed_at, payment_status)
VALUES (352, 5, now(), 'paid');
INSERT INTO ticket (ticket_id, order_id, event_id, seat_label, price, issued_at)
VALUES (454, 352, 200, 'B5', 15000, now());
SAVEPOINT second_seat;
INSERT INTO ticket (ticket_id, order_id, event_id, seat_label, price, issued_at)
VALUES (455, 352, 200, 'A1', 15000, now());
ROLLBACK TO SAVEPOINT second_seat;
INSERT INTO ticket (ticket_id, order_id, event_id, seat_label, price, issued_at)
VALUES (455, 352, 200, 'B6', 15000, now());
COMMIT;

SELECT order_id, ticket_id, seat_label FROM ticket WHERE order_id = 352 ORDER BY ticket_id;
