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

## Documents

- [Final summary](Ndianekwu_Chibuzor_301893177_FinalSummary.md)
- [Change log](Ndianekwu_Chibuzor_301893177_ChangeLog.md)
