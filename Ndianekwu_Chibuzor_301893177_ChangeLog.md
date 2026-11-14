# Change log: review of 14 November 2026

Each entry says what changed and why.

## Whole repository

| Change | Why |
| --- | --- |
| Every file renamed from `ndianekwu_...` to `Ndianekwu_...` | the submission format is Surname_Firstname_StudentID with a capital surname |
| Root README rewritten | the brief asks for the organisation, nature of the system, users, data and operations at the start, plus how the work is run |
| Rendered summary images removed from P1 to P4 | they showed the old one-row results; unedited psql output is now in each `evidence/` folder |
| Final summary PDF removed | it was 4 pages (limit 3) and described the old work; regenerate it from the updated summary |

## Portfolio 1

| Change | Why |
| --- | --- |
| New `customer` table; `ticket_order` now references it | the case study names customers as users, but they existed only as an email typed on each order (repeated data, no integrity) |
| CHECK lists on event status, payment status and ticket status | any text was accepted before |
| `capacity` is `integer` in schema, design and diagram | the schema said bigint while the documents said integer |
| Indexes on foreign key columns | PostgreSQL does not create them; joins and lookups scanned whole tables |
| Sample data grown from 1 row per table to 12 / 5 / 8 / 24 / 46 | one row cannot show joins, grouping or normalisation |
| Constraint tests: 15 cases with saved output | tests added for the new rules and for deleting a venue that has events |
| Normalisation rewritten as UNF → 1NF → 2NF → 3NF on a booking sheet | the old 2NF step said nothing changed, so no dependency was demonstrated |
| ER diagram redrawn | to include customer and the constraints |

## Portfolio 2

| Change | Why |
| --- | --- |
| Four new queries | the old ones did not cover "events by venue and start time" or "revenue by event", both promised in the case study |
| Index test moved to the real `ticket` table with 60,046 rows | the old test used a stand-in table with two columns |
| Counter-example added (query the index does not help) and index size reported | shows when an index is not used and what it costs |
| README analysis rewritten from the new plans | numbers now match the saved output |

## Portfolio 3

| Change | Why |
| --- | --- |
| Artificial counter column removed | the test changed the ticket table for no business reason |
| Commit, rollback and savepoint shown on a real order | demonstrates atomicity on the case study itself |
| Two-buyer overselling test, run three ways by a script | a real ticketing race; compares no control, row lock and SERIALIZABLE |
| Old SessionA/SessionB files replaced | the two sessions are now started by the runner so the timing is repeatable |

## Portfolio 4

| Change | Why |
| --- | --- |
| Document model simplified to order, event, tickets, details | the old model's source/embedded/references/via layers were hard to explain |
| Six documents of four types, dated 2026, matching SQL orders 300, 302, 315 | the old data had two near-identical documents dated 2030, and `order_placed` pointed at a ticket |
| Array query, aggregation with $unwind, and an explain() check added | uses features specific to the document model |
| Comment "four example events" corrected | the script inserted two |
| **Not yet run**: no MongoDB server was available during the review | run the script in mongosh and save the output into `evidence/` |

## Portfolio 5

| Change | Why |
| --- | --- |
| Broken sentence about PostgreSQL constraints fixed | it read "authoritative for Venue capacity must be greater than zero" |
| Collection description and shard key updated | to match the new Portfolio 4 model |

## Still open

- Individual reflection in the final summary: to be written by the student.
- AI-use declaration: left as it was. It does not mention this review.
- MongoDB output and real screenshots from the student's own machine.
- Timings in Portfolio 2 and timestamps in Portfolio 3 come from the review machine (PostgreSQL 16.15); they will differ on another computer.
- The brief asks for a private repository that the assessor can open.
