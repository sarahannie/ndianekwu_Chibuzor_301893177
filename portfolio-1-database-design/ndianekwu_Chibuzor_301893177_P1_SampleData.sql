-- Fictional sample records for Event Ticketing Platform.
BEGIN;
SET LOCAL standard_conforming_strings = on;
INSERT INTO portfolio."venue" ("venue_id", "name", "city", "capacity") VALUES (100, 'Harbor Hall', 'Portview', 500);
INSERT INTO portfolio."ticket_order" ("order_id", "customer_email", "placed_at", "payment_status") VALUES (300, 'guest@example.test', '2026-11-07T18:00:00Z', 'paid');
INSERT INTO portfolio."event" ("event_id", "venue_id", "title", "starts_at", "status", "capacity") VALUES (200, 100, 'Synthetic Jazz Night', '2026-12-10T19:00:00Z', 'scheduled', 300);
INSERT INTO portfolio."ticket" ("ticket_id", "order_id", "event_id", "seat_label", "price", "status", "issued_at") VALUES (400, 300, 200, 'A1', 45, 'issued', '2026-11-07T18:05:00Z');
COMMIT;
