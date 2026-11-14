# Event Ticketing Platform: database design

## Users

- Customers who browse events and buy tickets
- Event staff who schedule events and check sales
- Gate staff who scan tickets on the day
- Finance staff who report revenue

## Operations the design must support

- Create venues and schedule events in them
- Place an order and issue one or more tickets for it
- Find events by venue and start time
- Report tickets sold and revenue for each event
- Refuse a second sale of the same numbered seat

## Entities

| Entity | What it stores |
| --- | --- |
| customer | A person who buys tickets. Email is unique. |
| venue | A hall or arena with a city and a maximum capacity. |
| event | One scheduled show at one venue, with its own capacity and status. |
| ticket_order | One purchase by one customer, with payment status. |
| ticket | One admission to one event, bought in one order. Seat is optional. |

## Tables

### customer

| Field | Type | Key | Required | Rule |
| --- | --- | --- | --- | --- |
| customer_id | bigint | PK | Yes | |
| full_name | text | | Yes | |
| email | text | UNIQUE | Yes | one account per email |
| phone | text | | No | |

### venue

| Field | Type | Key | Required | Rule |
| --- | --- | --- | --- | --- |
| venue_id | bigint | PK | Yes | |
| name | text | | Yes | |
| city | text | | Yes | |
| capacity | integer | | Yes | capacity > 0 |

### event

| Field | Type | Key | Required | Rule |
| --- | --- | --- | --- | --- |
| event_id | bigint | PK | Yes | |
| venue_id | bigint | FK → venue | Yes | |
| title | text | | Yes | |
| starts_at | timestamptz | | Yes | |
| status | text | | Yes | scheduled, cancelled or completed |
| capacity | integer | | Yes | capacity > 0 |

### ticket_order

| Field | Type | Key | Required | Rule |
| --- | --- | --- | --- | --- |
| order_id | bigint | PK | Yes | |
| customer_id | bigint | FK → customer | Yes | |
| placed_at | timestamptz | | Yes | |
| payment_status | text | | Yes | pending, paid, failed or refunded |

### ticket

| Field | Type | Key | Required | Rule |
| --- | --- | --- | --- | --- |
| ticket_id | bigint | PK | Yes | |
| order_id | bigint | FK → ticket_order | Yes | |
| event_id | bigint | FK → event | Yes | |
| seat_label | text | | No | NULL means general admission |
| price | numeric(10,2) | | Yes | price > 0 |
| status | text | | Yes | issued, used or cancelled |
| issued_at | timestamptz | | Yes | |

Unique rule: (event_id, seat_label) is unique when seat_label is not NULL. This is a partial unique index, so any number of general admission tickets can exist for one event.

## Relationships

| Relationship | Cardinality | Enforced by |
| --- | --- | --- |
| customer places ticket_order | one to many | fk_order_customer |
| ticket_order contains ticket | one to many | fk_ticket_order |
| venue hosts event | one to many | fk_event_venue |
| event sells ticket | one to many | fk_ticket_event |

The foreign keys use the default NO ACTION, so a venue with events or an order with tickets cannot be deleted (constraint test 15).

## Indexes

| Index | Purpose |
| --- | --- |
| idx_event_venue_start (venue_id, starts_at) | find events by venue and date |
| idx_order_customer (customer_id) | a customer's order history |
| idx_ticket_order (order_id) | tickets of one order |
| idx_ticket_event (event_id) | sales for one event; created and measured in Portfolio 2 |

PostgreSQL creates indexes for primary keys and unique constraints but not for foreign key columns, so these were added by hand.

## Assumptions and limits

- All records are fictional. IDs are entered by hand so that tests can refer to known rows.
- Price is stored on the ticket because the same event can sell at different prices.
- Event capacity may be lower than venue capacity, for example when part of a hall is closed. The rule "event capacity must not exceed venue capacity" compares two tables, so a CHECK constraint cannot express it. It is not enforced in this schema.
- The rule "tickets sold must not exceed event capacity" also spans rows. It is handled in the purchase transaction in Portfolio 3.
