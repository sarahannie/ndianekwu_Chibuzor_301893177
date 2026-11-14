-- Portfolio 3, part 2: one buyer tries to take a general admission ticket for event 204.
-- Event 204 has capacity 3 and 2 tickets sold, so only ONE more ticket may be issued.
-- The buyer checks the count first and inserts afterwards (check, then act) with no lock.
-- psql variables: who, order_id, ticket_id, customer_id, iso, pause
SET search_path TO portfolio;
\set VERBOSITY verbose
BEGIN ISOLATION LEVEL :iso;
SELECT :'who' AS session, to_char(clock_timestamp(), 'HH24:MI:SS.MS') AS at, 'counting sold tickets' AS step;

SELECT count(*) AS sold, (SELECT capacity FROM event WHERE event_id = 204) AS capacity,
       count(*) < (SELECT capacity FROM event WHERE event_id = 204) AS seat_free
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
