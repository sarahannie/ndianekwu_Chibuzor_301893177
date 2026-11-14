# Portfolio 4: NoSQL and Advanced Data Models

| File | Content |
| --- | --- |
| [MongoDB script](Ndianekwu_Chibuzor_301893177_P4_MongoDB.js) | collection, validator, 6 documents, indexes, 6 queries, 3 validation tests |
| evidence/ | mongosh output of the script (see "Evidence" below) |

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

## Queries in the script

| # | Query | MongoDB feature | Expected documents |
| --- | --- | --- | --- |
| Q1 | Timeline of order 300 | dot notation on an embedded field, sort | 3 |
| Q2 | Activity in November 2026 | date range on a BSON Date | 5 |
| Q3 | Entries involving seat A1 | $elemMatch on an array | 2 |
| Q4 | Tickets issued and value per event | $match, $unwind, $group, $sort | 2 groups |
| Q5 | Entries per type | $group | 4 groups |
| Q6 | Plan for Q1 | explain("executionStats") | IXSCAN on order_timeline |

Validation tests: a text value in `occurredAt` and an unknown `eventType` should be rejected with code 121; a repeated `_id` with code 11000. The collection should still hold 6 documents.

## Evidence

The "expected" column above is worked out from the six sample documents. The script output must be captured by running:

```bash
mongosh --file Ndianekwu_Chibuzor_301893177_P4_MongoDB.js > evidence/Ndianekwu_Chibuzor_301893177_P4_MongoOutput.txt
```

## Reference

- MongoDB, Inc. *Data Modeling.* https://www.mongodb.com/docs/manual/data-modeling/
- MongoDB, Inc. *Schema Validation.* https://www.mongodb.com/docs/manual/core/schema-validation/
