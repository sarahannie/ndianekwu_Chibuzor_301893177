# MIT 8103 Advanced Database Systems: Portfolio Summary

**Ndianekwu Chibuzor Sarah · Student ID 301893177**

Repository: https://github.com/sarahannie/ndianekwu_Chibuzor_301893177

## Selected organisation

Event Ticketing Platform, a fictional Nigerian company selling tickets for concerts, shows and workshops at hired venues. Customers buy tickets; event, gate and finance staff schedule events, scan tickets and report revenue. The database stores customers, venues, events, orders, tickets and a log of ticket activity. It must schedule events, issue tickets, find events by venue and date, report revenue per event, and never sell a seat or the last place twice.

## Portfolio 1: Database Design and Modelling

Five PostgreSQL tables in third normal form: customer, venue, event, ticket_order, ticket. Rules are enforced with primary and foreign keys, NOT NULL, CHECK constraints on capacity, price and status values, a unique email, and a partial unique index that allows one ticket per numbered seat per event while leaving general admission tickets unrestricted. Sample data: 12 customers, 5 venues, 8 events, 24 orders, 46 tickets. All 15 invalid statements in the constraint tests were rejected and row counts were unchanged.

![ER diagram](images/Ndianekwu_Chibuzor_301893177_ERDiagram.png)

## Portfolio 2: Query Processing and Optimisation

Four queries cover the stated operations: events by venue and date, revenue per event, a customer's order history (five-table join), and events at least half sold. Each was run with EXPLAIN (ANALYZE, BUFFERS). For the index test, 60,000 tickets were added and the "sales for one event" lookup was measured three times each way.

| | Before index | After index on ticket(event_id) |
| --- | --- | --- |
| Plan | Seq Scan | Bitmap Index Scan + Bitmap Heap Scan |
| Pages read | 562 | 203 |
| Median time | 3.454 ms | 0.128 ms |

The result was the same (200 tickets). A query matching 58,000 rows still used the sequential scan, so the index only pays off for selective lookups. It added 416 kB and extra work on every insert.

## Portfolio 3: Transactions and Concurrency

An order with two seats committed as one unit. An order containing an already sold seat failed with error 23505 and ROLLBACK removed the whole order; a SAVEPOINT version kept the order and replaced only the failed seat. Two sessions then tried to buy the last place of an event with capacity 3:

| Method | Final tickets | Outcome |
| --- | --- | --- |
| READ COMMITTED, count then insert | 4 | oversold |
| SELECT ... FOR UPDATE on the event row | 3 | second buyer waited 1.99 s, then was refused |
| SERIALIZABLE | 3 | one transaction cancelled with 40001 |

## Portfolio 4: NoSQL and Advanced Data Models

A MongoDB collection, ticket_events, logs four kinds of activity (order placed, ticket issued, ticket scanned, order refunded). Customer, event and venue details are embedded so one read shows a full entry, and a details sub-document differs by type. A JSON Schema validator fixes the common fields. Two indexes support the order timeline and recent-activity reads. PostgreSQL stays the owner of current data and of the rules that need constraints.

## Portfolio 5: Distributed and Cloud Database Exercise

Discussion option. The proposal is a three-member MongoDB replica set across three availability zones, majority write concern, primary reads where committed data is required, and a hashed shard key on order.order_id if the log outgrows one replica set. Replication gives availability but not backup, and PostgreSQL needs its own high-availability setup. Nothing was deployed.

## Evidence

Each portfolio folder holds the scripts, a README and an evidence folder with the unedited script output.

## Individual reflection

[TO BE WRITTEN BY SARAH. Suggested points: why you chose ticketing; why seat_label is optional and how the partial unique index handles it; what surprised you in the overselling test; when you would pick a row lock over SERIALIZABLE; what the index test taught you about reading plans; what was hardest.]

## AI-use declaration

I used GitHub Copilot and the portfolio generator to help prepare the database model, scripts and explanations. The generator ran the PostgreSQL and MongoDB exercises, checked their outputs and captured the result images.  I remain responsible for checking and explaining the submitted work.

## References

- PostgreSQL Global Development Group (2026). *PostgreSQL 16 documentation*: Constraints; Using EXPLAIN; Indexes; Transaction Isolation; Explicit Locking. https://www.postgresql.org/docs/16/
- MongoDB, Inc. (2026). *MongoDB Manual*: Data Modeling; Schema Validation; Replication; Sharding. https://www.mongodb.com/docs/manual/
- Graphviz. https://graphviz.org/ and Mermaid ER diagrams. https://mermaid.js.org/syntax/entityRelationshipDiagram.html
