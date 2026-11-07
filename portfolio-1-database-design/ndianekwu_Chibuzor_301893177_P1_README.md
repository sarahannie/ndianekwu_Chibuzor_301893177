# Portfolio 1 — Database Design and Modelling

I organised the data into venue, event, ticket_order, ticket. The design document explains the fields, keys, relationships and business rules. The normalisation document shows the sample tables at 1NF, 2NF and 3NF.

## Database checks

| Table | Rows |
| --- | --- |
| venue | 1 |
| event | 1 |
| ticket_order | 1 |
| ticket | 1 |

The 12 invalid inserts were rejected at their expected constraints, and the valid sample rows remained unchanged.

## Files

- [Design](ndianekwu_Chibuzor_301893177_P1_Design.md)
- [ER diagram](ndianekwu_Chibuzor_301893177_P1_ERDiagram.md)
- [Normalisation](ndianekwu_Chibuzor_301893177_P1_Normalisation.md)
- [Schema](ndianekwu_Chibuzor_301893177_P1_Schema.sql)
- [Sample data](ndianekwu_Chibuzor_301893177_P1_SampleData.sql)
- [Constraint tests](ndianekwu_Chibuzor_301893177_P1_ConstraintTests.sql)
- [Table and constraint evidence](screenshots/ndianekwu_Chibuzor_301893177_P1_DatabaseResults.png)

## Run the SQL

Create a fresh PostgreSQL database. Run the schema first, then the sample data. Run the deliberately invalid statements in ConstraintTests.sql individually outside a transaction; each is expected to produce an error.

## References

- [PostgreSQL — constraints](https://www.postgresql.org/docs/17/ddl-constraints.html)

