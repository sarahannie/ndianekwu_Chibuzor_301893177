-- Event Ticketing Platform: tables, keys and business constraints.
-- Run once in a fresh PostgreSQL database.
BEGIN;
SET LOCAL standard_conforming_strings = on;
CREATE SCHEMA portfolio;
CREATE TABLE portfolio."venue" (
  "venue_id" bigint NOT NULL,
  "name" text NOT NULL,
  "city" text NOT NULL,
  "capacity" bigint NOT NULL,
  CONSTRAINT "pk_venue" PRIMARY KEY ("venue_id")
);
CREATE TABLE portfolio."event" (
  "event_id" bigint NOT NULL,
  "venue_id" bigint NOT NULL,
  "title" text NOT NULL,
  "starts_at" timestamptz NOT NULL,
  "status" text NOT NULL,
  "capacity" bigint NOT NULL,
  CONSTRAINT "pk_event" PRIMARY KEY ("event_id")
);
CREATE TABLE portfolio."ticket_order" (
  "order_id" bigint NOT NULL,
  "customer_email" text NOT NULL,
  "placed_at" timestamptz NOT NULL,
  "payment_status" text NOT NULL,
  CONSTRAINT "pk_ticket_order" PRIMARY KEY ("order_id")
);
CREATE TABLE portfolio."ticket" (
  "ticket_id" bigint NOT NULL,
  "order_id" bigint NOT NULL,
  "event_id" bigint NOT NULL,
  "seat_label" text,
  "price" numeric(18,2) NOT NULL,
  "status" text NOT NULL,
  "issued_at" timestamptz NOT NULL,
  CONSTRAINT "pk_ticket" PRIMARY KEY ("ticket_id")
);
ALTER TABLE portfolio."event" ADD CONSTRAINT "fk_event_0" FOREIGN KEY ("venue_id") REFERENCES portfolio."venue" ("venue_id");
ALTER TABLE portfolio."ticket" ADD CONSTRAINT "fk_ticket_0" FOREIGN KEY ("order_id") REFERENCES portfolio."ticket_order" ("order_id");
ALTER TABLE portfolio."ticket" ADD CONSTRAINT "fk_ticket_1" FOREIGN KEY ("event_id") REFERENCES portfolio."event" ("event_id");
ALTER TABLE portfolio."venue" ADD CONSTRAINT "venue_capacity_positive" CHECK ("capacity" > 0);
ALTER TABLE portfolio."event" ADD CONSTRAINT "event_capacity_positive" CHECK ("capacity" > 0);
ALTER TABLE portfolio."ticket" ADD CONSTRAINT "ticket_price_positive" CHECK ("price" > 0);
CREATE UNIQUE INDEX "ticket_seat_unique" ON portfolio."ticket" ("event_id", "seat_label") WHERE ("seat_label" IS NOT NULL);
COMMIT;
