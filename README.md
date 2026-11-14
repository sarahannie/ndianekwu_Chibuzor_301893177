# MIT 8103 Advanced Database Systems: Portfolio

**Ndianekwu Chibuzor Sarah · Student ID 301893177 · MIVA Open University, 2026/2027 first semester**

## Case study: Event Ticketing Platform

A fictional Nigerian company that sells tickets for concerts, shows and workshops held at hired venues.

| | |
| --- | --- |
| Nature of the system | Online ticket sales. Some events have numbered seats; others are general admission with a fixed capacity. |
| Database users | Customers buying tickets, event staff checking sales, gate staff scanning tickets, finance staff reporting revenue. |
| Main data | Customers, venues, events, ticket orders, tickets, and a log of ticket activity. |
| Key operations | Schedule an event at a venue, place an order and issue its tickets, find events by venue and date, report tickets sold and revenue per event, stop a seat or the last place being sold twice. |

All names, emails and amounts are invented. Prices are in naira.

## Portfolio activities

| Folder | Activity | Technology |
| --- | --- | --- |
| [portfolio-1-database-design](portfolio-1-database-design/) | ER diagram, schema, constraints, normalisation | PostgreSQL 16 |
| [portfolio-2-query-optimisation](portfolio-2-query-optimisation/) | Four queries, execution plans, index before/after test | PostgreSQL 16 |
| [portfolio-3-transactions-concurrency](portfolio-3-transactions-concurrency/) | Commit, rollback, savepoint, overselling race and two fixes | PostgreSQL 16 |
| [portfolio-4-nosql](portfolio-4-nosql/) | Ticket activity log as documents | MongoDB |
| [portfolio-5-distributed-cloud](portfolio-5-distributed-cloud/) | Replication, consistency, sharding and deployment discussion | MongoDB / PostgreSQL |

Each folder has its own README. Files in each `evidence/` folder are the unedited psql output from a local PostgreSQL 16 run. Files in each `screenshots/` folder are from MongoDB Atlas and from a Neon PostgreSQL 18.7 database.

## Run everything

```bash
createdb ticketing
psql -d ticketing -f portfolio-1-database-design/Ndianekwu_Chibuzor_301893177_P1_Schema.sql
psql -d ticketing -f portfolio-1-database-design/Ndianekwu_Chibuzor_301893177_P1_SampleData.sql
psql -d ticketing -f portfolio-1-database-design/Ndianekwu_Chibuzor_301893177_P1_ConstraintTests.sql
psql -d ticketing -f portfolio-2-query-optimisation/Ndianekwu_Chibuzor_301893177_P2_Queries.sql
psql -d ticketing -f portfolio-2-query-optimisation/Ndianekwu_Chibuzor_301893177_P2_Optimisation.sql
psql -d ticketing -f portfolio-3-transactions-concurrency/Ndianekwu_Chibuzor_301893177_P3_Transactions.sql
./portfolio-3-transactions-concurrency/Ndianekwu_Chibuzor_301893177_P3_RunConcurrency.sh "-d ticketing"
mongosh --file portfolio-4-nosql/Ndianekwu_Chibuzor_301893177_P4_MongoDB.js
```

Run the scripts in this order on an empty database. Portfolio 3 adds orders, so running Portfolio 2 after it changes the query results.

## Tools and environments

| Tool | Used for |
| --- | --- |
| PostgreSQL 16 (local psql) | All Portfolio 1–3 scripts; the `evidence/` text files are its unedited output |
| PostgreSQL 18.7 on Neon (web SQL editor) | Second run of selected steps, saved as screenshots; plan shapes and page counts match the local run |
| MongoDB Atlas, Cluster0 (MongoDB 8.0) | Portfolio 4, entered step by step in Data Explorer; the same steps are in the mongosh script |
| Graphviz | ER diagram in `images/` |

Requirements to rerun: PostgreSQL 16 with psql, bash, and mongosh (Portfolio 4 only).

## Running notes

- Run Portfolio 1 first; Portfolios 2 and 3 use its tables and sample data.
- The Portfolio 2 index test runs inside a transaction and is rolled back, so the data is unchanged afterwards.
- The Portfolio 3 runner starts two psql sessions one second apart and removes its test orders, so it can be repeated.
- For a clean rerun of Portfolio 4, drop the collection first: `db.ticket_events.drop()`.

## Key results

| Portfolio | Result |
| --- | --- |
| 1. Design | 15 of 15 invalid statements rejected (23505, 23503, 23514, 23502); general admission tickets with no seat accepted as intended; row counts unchanged at 12, 5, 8, 24, 46 |
| 2. Optimisation | Lookup over 60,046 tickets: Seq Scan median 3.454 ms → Bitmap Index Scan median 0.128 ms (about 27× faster), same answer; Neon: 7.083 ms → 0.371 ms |
| 3. Concurrency | READ COMMITTED count-then-insert oversold the event (4 of 3); `SELECT ... FOR UPDATE` held it at 3 of 3; SERIALIZABLE cancelled one buyer with 40001 |
| 4. NoSQL | Validator rejected a text date; Q1 went from COLLSCAN (6 documents examined) to IXSCAN (3 keys, 3 documents) after the compound index; aggregation totals match PostgreSQL |
| 5. Distributed | Design only: three-member replica set across zones, majority write concern, hashed shard key on `order.order_id` if the log grows; nothing was provisioned or tested |

## Evidence index

| Portfolio | `evidence/` (local PostgreSQL 16) | `screenshots/` |
| --- | --- | --- |
| 1 | TableDefinitions, ConstraintTestOutput | 2 Neon images |
| 2 | QueryOutput, IndexComparisonOutput | 3 Neon images |
| 3 | CommitRollbackOutput, ConcurrencyOutput | 2 Neon images |
| 4 | — | 10 MongoDB Atlas images |
| 5 | — | 1 architecture diagram |

## AI use

The declaration is in the final summary: Claude (Anthropic) helped with the database model description and explanation. The author is responsible for checking the narration, the individual influence on the work and the rest of the submitted work.

## Known limits

- Two PostgreSQL engines were used (16 locally, 18.7 on Neon); timings differ between them and are indicative only.
- The Neon index test measured each side once; the local run measured three times.
- Portfolio 3's two-buyer tests ran only on local PostgreSQL 16, because the web editor offers one connection.
- Some parts of the Portfolio 4 script (Q5, a second index, two rejection tests) were not run on Atlas.
- Portfolio 5 is a design discussion; no cloud service was built or tested.

## Documents

- [Final summary](Ndianekwu_Chibuzor_301893177_FinalSummary.md)
- [Final summary (PDF)](Ndianekwu_Chibuzor_301893177_FinalSummary.pdf)
- [ER diagram image](images/Ndianekwu_Chibuzor_301893177_ERDiagram.png)
