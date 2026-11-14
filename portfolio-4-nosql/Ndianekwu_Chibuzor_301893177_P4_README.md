# Portfolio 4: NoSQL and Advanced Data Models

| File | Content |
| --- | --- |
| [MongoDB script](Ndianekwu_Chibuzor_301893177_P4_MongoDB.js) | collection, validator, 6 documents, indexes, 6 queries, 3 validation tests |
| screenshots/ | ten Atlas Data Explorer screenshots, numbered in the order of the steps below |

## What is stored

PostgreSQL holds the current state: who owns which ticket. MongoDB holds the history: everything that happened to an order. The collection `ticket_events` is an activity log with four kinds of entry.

| eventType | Written when | Fields only this type has (in `details`) |
| --- | --- | --- |
| order_placed | a customer pays | channel, payment method and amount, promo code |
| ticket_issued | tickets are sent | delivery method |
| ticket_scanned | a ticket is checked at the gate | gate, scanner device, staff |
| order_refunded | money is returned | reason, refund amount and method |

## Document shape

```javascript
{
  _id: "evt-0002",
  eventType: "ticket_issued",
  occurredAt: ISODate("2026-11-01T08:05:00Z"),
  order: { order_id: 300,
           customer: { customer_id: 1, full_name: "Adaeze Okonkwo", email: "adaeze.okonkwo@example.test" } },
  event: { event_id: 200, title: "Lagos Jazz Night", starts_at: ISODate("2026-12-10T18:00:00Z"),
           venue: { venue_id: 100, name: "Harbour Hall", city: "Lagos" } },
  tickets: [ { ticket_id: 400, seat_label: "A1", price_naira: 15000 },
             { ticket_id: 401, seat_label: "A2", price_naira: 15000 } ],
  details: { delivery: "email" }
}
```

The IDs, names and prices are the same as orders 300, 302 and 315 in the PostgreSQL sample data.

## Design choices

| Choice | Reason | Cost |
| --- | --- | --- |
| Embed customer, event and venue in each entry | support staff read one document and see the whole picture; the log shows the names as they were at that moment | the same name is stored many times, and a later rename is not copied into old entries (correct for an audit log) |
| Embed tickets as an array | an order's tickets are always read with the entry and the list is short | not suitable if one entry could hold thousands of tickets |
| Keep only IDs for anything else | PostgreSQL remains the owner of current data | a second lookup is needed for live details |
| One document per activity | entries are only added, never grown, so documents stay small | a timeline needs a query, served by the order_timeline index |
| Free-form `details` with a validator on the common fields | each type carries different facts, and new types need no ALTER TABLE | mistakes inside `details` are not caught by the database |

## Why a document store suits this part

- In SQL the four entry types would need either four tables or one table with many NULL columns.
- Reading a timeline in SQL needs joins to customer, event and venue. Here it is one indexed read.
- The log is append-only and can grow far larger than the core tables, which fits MongoDB's replication and sharding (Portfolio 5).

It does not replace PostgreSQL. Seat uniqueness, foreign keys and the capacity check need constraints and multi-row transactions, which stay in the relational database.

## How it was implemented and tested

The collection was built on a MongoDB Atlas free cluster (MongoDB 8.0) on 14 November 2026, using the Atlas Data Explorer in the browser: validation rule first, then the six documents, then the queries. The [script](Ndianekwu_Chibuzor_301893177_P4_MongoDB.js) holds the same steps for mongosh; the results below are from the Atlas run.

| Step | What was done | Result | Evidence |
| --- | --- | --- | --- |
| 1 | Validation rule applied (action: error, level: strict) | accepted | [01](screenshots/Ndianekwu_Chibuzor_301893177_P4_01_ValidationRule.jpg) |
| 2 | Six documents inserted | 6 documents, dates stored as BSON Date | [02](screenshots/Ndianekwu_Chibuzor_301893177_P4_02_SixDocumentsInserted.jpg) |
| 3 | Q1: `{ "order.order_id": 300 }` (dot notation into an embedded document) | 3 documents | [03](screenshots/Ndianekwu_Chibuzor_301893177_P4_03_Q1_OrderTimeline.jpg) |
| 4 | Explain Q1 with no index | COLLSCAN, 6 documents examined, 0 index keys | [04](screenshots/Ndianekwu_Chibuzor_301893177_P4_04_Explain_BeforeIndex_COLLSCAN.jpg) |
| 5 | Compound index on `order.order_id` (asc), `occurredAt` (asc) | index ready | [05](screenshots/Ndianekwu_Chibuzor_301893177_P4_05_IndexCreated.jpg) |
| 6 | Explain Q1 again | IXSCAN then FETCH, 3 keys and 3 documents examined | [06](screenshots/Ndianekwu_Chibuzor_301893177_P4_06_Explain_AfterIndex_IXSCAN.jpg) |
| 7 | Q3: `{ tickets: { $elemMatch: { seat_label: "A1" } } }` (match inside an array) | 2 documents: evt-0002, evt-0005 | [07](screenshots/Ndianekwu_Chibuzor_301893177_P4_07_Q3_SeatA1_ElemMatch.jpg) |
| 8 | Q2: `occurredAt` from 1 Nov to 1 Dec 2026 (date range) | 5 documents | [08](screenshots/Ndianekwu_Chibuzor_301893177_P4_08_Q2_NovemberDateRange.jpg) |
| 9 | Insert a document whose `occurredAt` is the text "2026-11-05" | refused: "Document failed validation" | [09](screenshots/Ndianekwu_Chibuzor_301893177_P4_09_ValidationRejected.jpg) |
| 10 | Q4: `$match`, `$unwind`, `$group`, `$sort` | Afrobeats Live: 4 tickets, 100,000; Lagos Jazz Night: 2 tickets, 30,000 | [10](screenshots/Ndianekwu_Chibuzor_301893177_P4_10_Q4_Aggregation.jpg) |

### What the results show

- Before the index MongoDB read every document to find order 300. After it, the documents examined equal the documents returned, so no work is wasted. With six documents both take 0 ms; the ratio is what matters as the log grows.
- The index starts with `order.order_id` and continues with `occurredAt`, so it also returns an order's entries already in time order.
- Q4's totals match PostgreSQL: order 302 has four tickets at 25,000 and order 300 has two at 15,000.
- The validator caught a wrong type on a common field. It would not catch a mistake inside `details`, which is free-form by design.

### Not run on Atlas

The script also contains a count per event type (Q5), a second index on `eventType` and `occurredAt`, and two more rejection tests (unknown event type, repeated `_id`). These were not executed in the Atlas session.

## Reference

- MongoDB, Inc. *Data Modeling.* https://www.mongodb.com/docs/manual/data-modeling/
- MongoDB, Inc. *Schema Validation.* https://www.mongodb.com/docs/manual/core/schema-validation/
