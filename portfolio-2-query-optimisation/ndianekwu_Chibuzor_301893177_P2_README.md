# Event Ticketing Platform — SQL queries

## 1. Show related ticket, ticket_order, event records (up to 20).

```sql
SELECT t0."ticket_id" AS "ticket_ticket_id",
       t0."seat_label" AS "ticket_seat_label",
       t1."order_id" AS "ticket_order_order_id",
       t1."customer_email" AS "ticket_order_customer_email",
       t2."event_id" AS "event_event_id",
       t2."title" AS "event_title"
FROM portfolio."ticket" t0
JOIN portfolio."ticket_order" t1 ON t0."order_id" = t1."order_id"
JOIN portfolio."event" t2 ON t0."event_id" = t2."event_id"
ORDER BY t0."ticket_id", t1."order_id", t2."event_id"
LIMIT 20;
```

| ticket_ticket_id | ticket_seat_label | ticket_order_order_id | ticket_order_customer_email | event_event_id | event_title |
| --- | --- | --- | --- | --- | --- |
| 400 | A1 | 300 | guest@example.test | 200 | Synthetic Jazz Night |

## 2. Find event records where venue_id matches 100 (up to 20).

```sql
SELECT * FROM portfolio."event"
WHERE "venue_id" IS NOT DISTINCT FROM 100
ORDER BY "event_id"
LIMIT 20;
```

| event_id | venue_id | title | starts_at | status | capacity |
| --- | --- | --- | --- | --- | --- |
| 200 | 100 | Synthetic Jazz Night | 2026-12-10T19:00:00+00:00 | scheduled | 300 |

## 3. Count ticket records for each order_id (up to 20 groups).

```sql
SELECT "order_id", count(*) AS record_count
FROM portfolio."ticket"
GROUP BY "order_id"
ORDER BY record_count DESC, "order_id" NULLS LAST
LIMIT 20;
```

| order_id | record_count |
| --- | --- |
| 300 | 1 |


## Index comparison

| Phase | Median (ms) | Three runs (ms) | Plan nodes | Buffer hits |
| --- | --- | --- | --- | --- |
| Before index | 1.154 | 1.154, 1.154, 1.165 | Sort → Seq Scan | 139 |
| After index | 0.263 | 0.232, 0.263, 0.277 | Sort → Bitmap Heap Scan → Bitmap Index Scan | 30 |

The median execution time changed from 1.154 ms to 0.263 ms. The measured plan used p2_filter_idx. The results matched in both phases. An index adds storage and write-maintenance costs; timings depend on the selected lookup and environment.

## Execution plans

### Before index, run 1

```text
Sort (actual time=1.124..1.126 rows=25 loops=1)
  Seq Scan on ticket (actual time=0.019..1.089 rows=25 loops=1)
Planning Time: 0.34 ms
Execution Time: 1.154 ms
```

### Before index, run 2

```text
Sort (actual time=1.124..1.126 rows=25 loops=1)
  Seq Scan on ticket (actual time=0.019..1.088 rows=25 loops=1)
Planning Time: 0.318 ms
Execution Time: 1.154 ms
```

### Before index, run 3

```text
Sort (actual time=1.136..1.138 rows=25 loops=1)
  Seq Scan on ticket (actual time=0.018..1.104 rows=25 loops=1)
Planning Time: 0.312 ms
Execution Time: 1.165 ms
```

### After index, run 1

```text
Sort (actual time=0.177..0.179 rows=25 loops=1)
  Bitmap Heap Scan on ticket (actual time=0.034..0.141 rows=25 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.016..0.016 rows=25 loops=1)
Planning Time: 0.493 ms
Execution Time: 0.232 ms
```

### After index, run 2

```text
Sort (actual time=0.191..0.193 rows=25 loops=1)
  Bitmap Heap Scan on ticket (actual time=0.053..0.139 rows=25 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.028..0.028 rows=25 loops=1)
Planning Time: 0.563 ms
Execution Time: 0.263 ms
```

### After index, run 3

```text
Sort (actual time=0.204..0.207 rows=25 loops=1)
  Bitmap Heap Scan on ticket (actual time=0.045..0.152 rows=25 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.024..0.024 rows=25 loops=1)
Planning Time: 0.735 ms
Execution Time: 0.277 ms
```

## Reproduce

Use a fresh database with the Portfolio 1 schema and sample data. Run ndianekwu_Chibuzor_301893177_P2_Queries.sql, then ndianekwu_Chibuzor_301893177_P2_Optimisation.sql. The optimisation script creates a separate performance table and runs EXPLAIN (ANALYZE, BUFFERS).

[Query screenshot](screenshots/ndianekwu_Chibuzor_301893177_P2_QueryResults.png) · [Index comparison](screenshots/ndianekwu_Chibuzor_301893177_P2_IndexComparison.png)

## References

- [PostgreSQL — EXPLAIN](https://www.postgresql.org/docs/17/using-explain.html)

