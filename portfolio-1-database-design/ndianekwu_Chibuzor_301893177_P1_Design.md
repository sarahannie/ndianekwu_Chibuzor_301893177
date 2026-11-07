# Event Ticketing Platform — database design

My case study records venue, event, ticket_order, ticket.

## Users

- Customers browsing events and placing ticket orders
- Event staff reviewing ticket sales

## Main operations

- Create venues and schedule events
- Place orders and issue tickets
- Find events by venue and start time
- Summarize issued tickets and revenue by event

## Entities

| Entity | Information stored |
| --- | --- |
| venue | Stores a venue's identifying name, city, and positive reference capacity. |
| event | Stores scheduled events and the venue hosting each event. |
| ticket_order | Stores the customer contact and placement time for an order. |
| ticket | Stores each ticket's event, order, optional seat, price, and issue status. |

## venue

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| venue_id | BIGINT | PK | Yes |
| name | TEXT |  | Yes |
| city | TEXT |  | Yes |
| capacity | INTEGER |  | Yes |


## event

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| event_id | BIGINT | PK | Yes |
| venue_id | BIGINT | FK | Yes |
| title | TEXT |  | Yes |
| starts_at | TIMESTAMPTZ |  | Yes |
| status | TEXT |  | Yes |
| capacity | INTEGER |  | Yes |
- venue_id → venue.venue_id

## ticket_order

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| order_id | BIGINT | PK | Yes |
| customer_email | TEXT |  | Yes |
| placed_at | TIMESTAMPTZ |  | Yes |
| payment_status | TEXT |  | Yes |


## ticket

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| ticket_id | BIGINT | PK | Yes |
| order_id | BIGINT | FK | Yes |
| event_id | BIGINT | FK | Yes |
| seat_label | TEXT |  | No |
| price | NUMERIC(18,2) |  | Yes |
| status | TEXT |  | Yes |
| issued_at | TIMESTAMPTZ |  | Yes |
- order_id → ticket_order.order_id
- event_id → event.event_id

## Relationships and business rules

- Venue capacity must be greater than zero.
- Every event must reference an existing venue through venue_id.
- Event reference capacity must be greater than zero.
- Every ticket must reference an existing ticket_order through order_id.
- Every ticket must reference an existing event through event_id.
- Ticket price must be greater than zero.
- For a given event, a non-null seat label may be assigned to at most one ticket; null labels are excluded.

## Assumptions

- All identifiers and example data are synthetic; primary-key values are globally unique across all tables.
- A ticket may have a null seat_label for general admission; a non-null seat label identifies a seat within one event.
- For a simple normalization example, begin with an event listing containing event_id, venue_id, venue_name, venue_city, venue_capacity, title, starts_at, status, and event_capacity. event_id determines the event attributes, while venue_id determines venue_name, venue_city, and venue_capacity. Split venue facts into venue and retain venue_id as the foreign key in event; this example has no repeated ancestor roles.
- Separate benchmark plan: create 25,000 synthetic ticket rows, compare the same selective ticket lookup by event_id before and after a B-tree index on ticket.event_id, and record the query plan and elapsed time under the same test conditions.

