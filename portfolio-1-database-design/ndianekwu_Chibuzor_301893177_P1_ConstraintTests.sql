-- Run these deliberately invalid statements one at a time, outside a transaction.
-- Each should fail at the named constraint; the sample rows should remain unchanged.

-- 1. reject pk venue. Expected: pk_venue, SQLSTATE 23505.
INSERT INTO portfolio."venue" ("venue_id", "name", "city", "capacity")
VALUES (100, 'Duplicate Key Venue', 'Portview', 100);

-- 2. reject pk event. Expected: pk_event, SQLSTATE 23505.
INSERT INTO portfolio."event" ("event_id", "venue_id", "title", "starts_at", "status", "capacity")
VALUES (200, 100, 'Duplicate Key Event', '2026-12-11T19:00:00Z', 'scheduled', 100);

-- 3. reject pk ticket order. Expected: pk_ticket_order, SQLSTATE 23505.
INSERT INTO portfolio."ticket_order" ("order_id", "customer_email", "placed_at", "payment_status")
VALUES (300, 'other@example.test', '2026-11-07T18:10:00Z', 'paid');

-- 4. reject pk ticket. Expected: pk_ticket, SQLSTATE 23505.
INSERT INTO portfolio."ticket" ("ticket_id", "order_id", "event_id", "seat_label", "price", "status", "issued_at")
VALUES (400, 300, 200, 'A2', 50, 'issued', '2026-11-07T18:10:00Z');

-- 5. reject fk event venue. Expected: fk_event_0, SQLSTATE 23503.
INSERT INTO portfolio."event" ("event_id", "venue_id", "title", "starts_at", "status", "capacity")
VALUES (201, 999, 'Missing Venue Event', '2026-12-12T19:00:00Z', 'scheduled', 100);

-- 6. reject fk ticket order. Expected: fk_ticket_0, SQLSTATE 23503.
INSERT INTO portfolio."ticket" ("ticket_id", "order_id", "event_id", "seat_label", "price", "status", "issued_at")
VALUES (401, 999, 200, 'A2', 50, 'issued', '2026-11-07T18:10:00Z');

-- 7. reject fk ticket event. Expected: fk_ticket_1, SQLSTATE 23503.
INSERT INTO portfolio."ticket" ("ticket_id", "order_id", "event_id", "seat_label", "price", "status", "issued_at")
VALUES (402, 300, 999, 'A2', 50, 'issued', '2026-11-07T18:10:00Z');

-- 8. reject check venue capacity. Expected: venue_capacity_positive, SQLSTATE 23514.
INSERT INTO portfolio."venue" ("venue_id", "name", "city", "capacity")
VALUES (101, 'Zero Capacity Venue', 'Portview', 0);

-- 9. reject check event capacity. Expected: event_capacity_positive, SQLSTATE 23514.
INSERT INTO portfolio."event" ("event_id", "venue_id", "title", "starts_at", "status", "capacity")
VALUES (202, 100, 'Zero Capacity Event', '2026-12-13T19:00:00Z', 'scheduled', 0);

-- 10. reject check ticket price. Expected: ticket_price_positive, SQLSTATE 23514.
INSERT INTO portfolio."ticket" ("ticket_id", "order_id", "event_id", "seat_label", "price", "status", "issued_at")
VALUES (403, 300, 200, 'A3', 0, 'issued', '2026-11-07T18:10:00Z');

-- 11. reject partial unique ticket seat. Expected: ticket_seat_unique, SQLSTATE 23505.
INSERT INTO portfolio."ticket" ("ticket_id", "order_id", "event_id", "seat_label", "price", "status", "issued_at")
VALUES (404, 300, 200, 'A1', 45, 'issued', '2026-11-07T18:10:00Z');

-- 12. reject not null venue name. Expected: name, SQLSTATE 23502.
INSERT INTO portfolio."venue" ("venue_id", "name", "city", "capacity")
VALUES (102, NULL, 'Portview', 100);
