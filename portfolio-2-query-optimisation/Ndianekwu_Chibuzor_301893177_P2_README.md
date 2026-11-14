# Portfolio 2: Query Processing and Optimisation

| File | Content |
| --- | --- |
| [Queries](Ndianekwu_Chibuzor_301893177_P2_Queries.sql) | Four queries, each followed by EXPLAIN (ANALYZE, BUFFERS) |
| [Query output](evidence/Ndianekwu_Chibuzor_301893177_P2_QueryOutput.txt) | Results and execution plans |
| [Optimisation](Ndianekwu_Chibuzor_301893177_P2_Optimisation.sql) | Index before/after test on the ticket table |
| [Index comparison output](evidence/Ndianekwu_Chibuzor_301893177_P2_IndexComparisonOutput.txt) | All six measured plans |

## Queries

| # | Question | SQL features | Rows |
| --- | --- | --- | --- |
| Q1 | Events at Garden Arena in December 2026 | range filter, ORDER BY | 1 |
| Q2 | Tickets sold and revenue per event | LEFT JOIN, GROUP BY, SUM, COALESCE | 8 |
| Q3 | Order history of one customer | five-table join | 4 |
| Q4 | Scheduled events at least half sold | JOIN, GROUP BY, HAVING | 1 |

Q2 uses a LEFT JOIN so that Harmattan Food Fair, whose tickets were all cancelled, still appears with 0 sold. An inner join would drop it from the report.

### What the plans show on the small sample

| Query | Plan chosen | Why |
| --- | --- | --- |
| Q1 | Index Scan on idx_event_venue_start | the index starts with venue_id and continues with starts_at, the same shape as the filter |
| Q2 | Seq Scan on both tables, Hash Left Join, HashAggregate | every event is needed, so reading the whole table is cheapest |
| Q3 | Index Scan on customer_email_unique, then nested loops through idx_order_customer, idx_ticket_order and the primary keys | one customer leads to few rows at each step |

## Index test

**Question:** how many tickets were sold for one event, and for how much?

```sql
SELECT count(*), sum(price) FROM ticket
WHERE event_id = 1042 AND status IN ('issued', 'used');
```

**Setup:** 300 extra events, 3,000 orders and 60,000 tickets were generated with generate_series, giving 60,046 ticket rows. The query matches 200 of them. It was run once to warm the cache, then measured three times before and three times after `CREATE INDEX idx_ticket_event ON ticket (event_id)`. The whole test runs inside a transaction that is rolled back.

| | Before index | After index |
| --- | --- | --- |
| Plan | Seq Scan on ticket | Bitmap Index Scan on idx_ticket_event, then Bitmap Heap Scan |
| Rows read and discarded | 59,846 | 0 |
| Buffers (8 kB pages) | 562 | 203 |
| Execution time, three runs (ms) | 3.675, 3.450, 3.454 | 0.128, 0.111, 0.130 |
| Median (ms) | 3.454 | 0.128 |
| Result | 200 tickets, 1,500,000.00 | 200 tickets, 1,500,000.00 |

### Analysis

- The median fell from 3.454 ms to 0.128 ms, about 27 times faster. The answer is identical.
- Without the index PostgreSQL read all 562 pages and threw away 59,846 rows. With it, 3 index pages pointed to the 200 pages that hold the matching rows.
- The 200 matching rows sit on 200 different pages because tickets for many events are sold in mixed order. That is why the page count only dropped to 203 and not lower.
- The planner does not always use the index. For `event_id > 1010`, which matches 58,000 of 60,046 rows, it kept the sequential scan (see the last plan in the output). An index helps when few rows match.
- Cost: the index took 416 kB next to a 4,496 kB table, and every ticket insert must now update it as well.
- The timings come from one machine with all data in memory. They show the direction and scale, not fixed values.

## Second run on a hosted database

The revenue query and the index test were repeated on Neon PostgreSQL 18.7 (web SQL editor, 14 November 2026). Each test loaded the same 60,000 extra tickets inside a transaction and rolled it back.

| | Before index | After index |
| --- | --- | --- |
| Plan | Seq Scan on ticket | Bitmap Index Scan, then Bitmap Heap Scan |
| Rows read and discarded | 59,846 | 0 |
| Buffers | 562 | 206 (203 hit, 3 read) |
| Execution time (one run each) | 7.083 ms | 0.371 ms |
| Screenshot | [02](screenshots/Ndianekwu_Chibuzor_301893177_P2_02_Plan_BeforeIndex_SeqScan_Neon.jpg) | [03](screenshots/Ndianekwu_Chibuzor_301893177_P2_03_Plan_AfterIndex_BitmapScan_Neon.jpg) |

The plans and page counts match the local PostgreSQL 16 run. The times differ because it is a different machine, and here each side was measured once, not three times. The revenue query returned the same eight rows ([01](screenshots/Ndianekwu_Chibuzor_301893177_P2_01_RevenuePerEvent_Neon.jpg)).

## Run

```bash
psql -d ticketing -f Ndianekwu_Chibuzor_301893177_P2_Queries.sql
psql -d ticketing -f Ndianekwu_Chibuzor_301893177_P2_Optimisation.sql
```

## References

- PostgreSQL Global Development Group. *Using EXPLAIN.* https://www.postgresql.org/docs/16/using-explain.html
- PostgreSQL Global Development Group. *Indexes.* https://www.postgresql.org/docs/16/indexes.html
