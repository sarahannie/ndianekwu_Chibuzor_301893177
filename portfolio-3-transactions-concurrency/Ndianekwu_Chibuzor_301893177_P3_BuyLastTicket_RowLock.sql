-- Portfolio 3, part 2: the same purchase, but the buyer first locks the event row.
-- SELECT ... FOR UPDATE makes a second buyer of the same event wait until the first one finishes,
-- so the count it reads afterwards already includes the first buyer's ticket.
-- psql variables: who, order_id, ticket_id, customer_id, pause
SET search_path TO portfolio;
\set VERBOSITY verbose
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT :'who' AS session, to_char(clock_timestamp(), 'HH24:MI:SS.MS') AS at, 'asking for the event row lock' AS step;

SELECT capacity FROM event WHERE event_id = 204 FOR UPDATE \gset
SELECT :'who' AS session, to_char(clock_timestamp(), 'HH24:MI:SS.MS') AS at, 'got the lock' AS step;

SELECT count(*) AS sold, count(*) < :capacity AS seat_free
FROM ticket WHERE event_id = 204 AND status <> 'cancelled' \gset
\echo :who sees sold = :sold , capacity = :capacity , seat_free = :seat_free

\if :seat_free
  INSERT INTO ticket_order (order_id, customer_id, placed_at, payment_status)
  VALUES (:order_id, :customer_id, now(), 'paid');
  INSERT INTO ticket (ticket_id, order_id, event_id, price, issued_at)
  VALUES (:ticket_id, :order_id, 204, 20000, now());
  \echo :who inserted ticket :ticket_id (not committed yet)
  SELECT pg_sleep(:pause);
  COMMIT;
\else
  \echo :who found the event full and bought nothing
  ROLLBACK;
\endif
SELECT :'who' AS session, to_char(clock_timestamp(), 'HH24:MI:SS.MS') AS at, 'finished' AS step;
