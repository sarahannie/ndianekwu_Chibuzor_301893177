-- Event Ticketing Platform: tables, keys and business rules.
-- Tested on PostgreSQL 16. Run once in an empty database.
BEGIN;

CREATE SCHEMA portfolio;
SET LOCAL search_path TO portfolio;

CREATE TABLE customer (
  customer_id bigint PRIMARY KEY,
  full_name   text   NOT NULL,
  email       text   NOT NULL,
  phone       text,
  CONSTRAINT customer_email_unique UNIQUE (email)
);

CREATE TABLE venue (
  venue_id bigint  PRIMARY KEY,
  name     text    NOT NULL,
  city     text    NOT NULL,
  capacity integer NOT NULL,
  CONSTRAINT venue_capacity_positive CHECK (capacity > 0)
);

CREATE TABLE event (
  event_id  bigint      PRIMARY KEY,
  venue_id  bigint      NOT NULL,
  title     text        NOT NULL,
  starts_at timestamptz NOT NULL,
  status    text        NOT NULL DEFAULT 'scheduled',
  capacity  integer     NOT NULL,
  CONSTRAINT fk_event_venue FOREIGN KEY (venue_id) REFERENCES venue (venue_id),
  CONSTRAINT event_capacity_positive CHECK (capacity > 0),
  CONSTRAINT event_status_valid CHECK (status IN ('scheduled', 'cancelled', 'completed'))
);

CREATE TABLE ticket_order (
  order_id       bigint      PRIMARY KEY,
  customer_id    bigint      NOT NULL,
  placed_at      timestamptz NOT NULL,
  payment_status text        NOT NULL DEFAULT 'pending',
  CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customer (customer_id),
  CONSTRAINT order_payment_status_valid
    CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded'))
);

CREATE TABLE ticket (
  ticket_id  bigint        PRIMARY KEY,
  order_id   bigint        NOT NULL,
  event_id   bigint        NOT NULL,
  seat_label text,                      -- NULL means general admission
  price      numeric(10,2) NOT NULL,    -- naira
  status     text          NOT NULL DEFAULT 'issued',
  issued_at  timestamptz   NOT NULL,
  CONSTRAINT fk_ticket_order FOREIGN KEY (order_id) REFERENCES ticket_order (order_id),
  CONSTRAINT fk_ticket_event FOREIGN KEY (event_id) REFERENCES event (event_id),
  CONSTRAINT ticket_price_positive CHECK (price > 0),
  CONSTRAINT ticket_status_valid CHECK (status IN ('issued', 'used', 'cancelled'))
);

-- A numbered seat can be sold once per event. General admission rows (NULL seat) are not affected.
CREATE UNIQUE INDEX ticket_seat_unique ON ticket (event_id, seat_label)
  WHERE seat_label IS NOT NULL;

-- PostgreSQL does not index foreign key columns automatically.
CREATE INDEX idx_event_venue_start ON event (venue_id, starts_at);
CREATE INDEX idx_order_customer    ON ticket_order (customer_id);
CREATE INDEX idx_ticket_order      ON ticket (order_id);
-- ticket.event_id is indexed in Portfolio 2, where the effect is measured.

COMMIT;
