# Portfolio 1: Database Design and Modelling

The relational design has five tables: customer, venue, event, ticket_order and ticket.

| File | Content |
| --- | --- |
| [Design](Ndianekwu_Chibuzor_301893177_P1_Design.md) | Entities, fields, keys, business rules and assumptions |
| [ER diagram](Ndianekwu_Chibuzor_301893177_P1_ERDiagram.md) | Mermaid source and image |
| [Normalisation](Ndianekwu_Chibuzor_301893177_P1_Normalisation.md) | One booking sheet taken from unnormalised form to 3NF |
| [Schema](Ndianekwu_Chibuzor_301893177_P1_Schema.sql) | CREATE TABLE statements, constraints and indexes |
| [Sample data](Ndianekwu_Chibuzor_301893177_P1_SampleData.sql) | 12 customers, 5 venues, 8 events, 24 orders, 46 tickets |
| [Constraint tests](Ndianekwu_Chibuzor_301893177_P1_ConstraintTests.sql) | 15 invalid statements and 1 valid edge case |
| [Constraint test output](evidence/Ndianekwu_Chibuzor_301893177_P1_ConstraintTestOutput.txt) | psql output of the tests |
| [Table definitions](evidence/Ndianekwu_Chibuzor_301893177_P1_TableDefinitions.txt) | `\d` output from psql |

## How it was tested

The schema and sample data were loaded into an empty PostgreSQL 16 database. The constraint test file was then run with psql.

| Check | Result |
| --- | --- |
| Invalid statements rejected | 15 of 15 |
| Error classes seen | 23505 unique, 23503 foreign key, 23514 check, 23502 not null |
| Two general admission tickets (NULL seat) for one event | accepted, as intended |
| Row counts before and after | unchanged: 12, 5, 8, 24, 46 |

## Run

```bash
createdb ticketing
psql -d ticketing -f Ndianekwu_Chibuzor_301893177_P1_Schema.sql
psql -d ticketing -f Ndianekwu_Chibuzor_301893177_P1_SampleData.sql
psql -d ticketing -f Ndianekwu_Chibuzor_301893177_P1_ConstraintTests.sql
```

## Reference

- PostgreSQL Global Development Group. *PostgreSQL documentation: Constraints.* https://www.postgresql.org/docs/16/ddl-constraints.html
