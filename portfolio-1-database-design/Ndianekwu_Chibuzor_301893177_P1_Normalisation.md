# Event Ticketing Platform: normalisation

The example starts from one line of a booking sheet, the way a box office might keep it in a spreadsheet. The values are order 300 from the sample data.

## Unnormalised form

| order_id | customer_name | customer_email | event_title | venue_name | venue_city | seats | prices |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 300 | Adaeze Okonkwo | adaeze.okonkwo@example.test | Lagos Jazz Night | Harbour Hall | Lagos | A1, A2 | 15000, 15000 |

Problem: `seats` and `prices` hold lists. A single seat cannot be searched, priced or cancelled on its own.

## 1NF: one value in each cell

Each ticket gets its own row. The key becomes (order_id, ticket_id).

| order_id | ticket_id | customer_name | customer_email | event_id | event_title | venue_name | venue_city | seat | price |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 300 | 400 | Adaeze Okonkwo | adaeze.okonkwo@example.test | 200 | Lagos Jazz Night | Harbour Hall | Lagos | A1 | 15000 |
| 300 | 401 | Adaeze Okonkwo | adaeze.okonkwo@example.test | 200 | Lagos Jazz Night | Harbour Hall | Lagos | A2 | 15000 |

Problem: the customer's name and email repeat on every ticket row. They depend on order_id alone, which is only part of the key. That is a partial dependency.

## 2NF: every non-key field depends on the whole key

Order facts move to their own table. Ticket facts stay with the ticket.

**order**

| order_id | customer_name | customer_email |
| --- | --- | --- |
| 300 | Adaeze Okonkwo | adaeze.okonkwo@example.test |

**ticket**

| ticket_id | order_id | event_id | event_title | venue_name | venue_city | seat | price |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 400 | 300 | 200 | Lagos Jazz Night | Harbour Hall | Lagos | A1 | 15000 |
| 401 | 300 | 200 | Lagos Jazz Night | Harbour Hall | Lagos | A2 | 15000 |

Problem: in `ticket`, the title depends on event_id, and the venue name and city depend on the venue. These are non-key fields depending on other non-key fields (transitive dependencies). In `order`, the name depends on the customer, not on the order. Renaming Harbour Hall would mean editing every ticket ever sold there.

## 3NF: non-key fields depend on the key and nothing else

| Table | Functional dependency |
| --- | --- |
| customer | customer_id → full_name, email, phone |
| venue | venue_id → name, city, capacity |
| event | event_id → venue_id, title, starts_at, status, capacity |
| ticket_order | order_id → customer_id, placed_at, payment_status |
| ticket | ticket_id → order_id, event_id, seat_label, price, status, issued_at |

These are the five tables in the schema. Each fact is stored once: a venue name in `venue`, an event title in `event`, a customer email in `customer`.

## Check

Query 3 in Portfolio 2 joins the five tables for Adaeze Okonkwo and returns the original booking sheet lines (seats A1 and A2 at Lagos Jazz Night, Harbour Hall), so no information was lost by splitting the tables.

## One deliberate exception

`ticket.price` could be seen as depending on the event. It is kept on the ticket because early-bird and regular tickets for the same event can differ in price, and a later price change must not rewrite past sales.
