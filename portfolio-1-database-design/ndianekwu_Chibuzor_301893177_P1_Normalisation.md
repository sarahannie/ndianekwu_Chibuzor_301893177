# Event Ticketing Platform — normalisation

The example uses the saved sample records. The full set of fields is in the design and schema.

## Starting grouped records

| venue_id | event records (list) |
| --- | --- |
| 100 | [200] |


The record IDs are grouped in a list. In 1NF, each record has its own row and each cell holds one value.

## 1NF: one value per cell

| event.event_id | event.venue_id | event.title | venue.venue_id | venue.name |
| --- | --- | --- | --- | --- |
| 200 | 100 | Synthetic Jazz Night | 100 | Harbor Hall |

Key: event_id.

## 2NF: depend on the whole key

The declared candidate keys do not introduce a partial dependency here, so the 1NF rows stay unchanged at this step.

## event_example

| event.event_id | event.venue_id | event.title | venue.venue_id | venue.name |
| --- | --- | --- | --- | --- |
| 200 | 100 | Synthetic Jazz Night | 100 | Harbor Hall |

## 3NF: store each entity’s details once

The entity keys determine their own descriptions. Related records keep foreign keys rather than repeating those descriptions.

## venue

| venue_id | name | city | capacity |
| --- | --- | --- | --- |
| 100 | Harbor Hall | Portview | 500 |

## event

| event_id | venue_id | title | starts_at | status | capacity |
| --- | --- | --- | --- | --- | --- |
| 200 | 100 | Synthetic Jazz Night | 2026-12-10T19:00:00+00:00 | scheduled | 300 |

## ticket_order

| order_id | customer_email | placed_at | payment_status |
| --- | --- | --- | --- |
| 300 | guest@example.test | 2026-11-07T18:00:00+00:00 | paid |

## ticket

| ticket_id | order_id | event_id | seat_label | price | status | issued_at |
| --- | --- | --- | --- | --- | --- | --- |
| 400 | 300 | 200 | A1 | 45 | issued | 2026-11-07T18:05:00+00:00 |

## Dependencies

- venue: (venue_id) → name, city, capacity
- event: (event_id) → venue_id, title, starts_at, status, capacity
- ticket_order: (order_id) → customer_email, placed_at, payment_status
- ticket: (ticket_id) → order_id, event_id, seat_label, price, status, issued_at

Joining the decomposed sample tables reproduces the original 1 example rows. The design assumes the declared keys describe the relevant business dependencies.
