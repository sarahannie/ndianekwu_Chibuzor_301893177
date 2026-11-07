# Event Ticketing Platform — ER diagram

```mermaid
erDiagram
    direction LR
    venue {
        bigint venue_id PK
        text name
        text city
        integer capacity
    }
    event {
        bigint event_id PK
        bigint venue_id FK
        text title
        timestamptz starts_at
        text status
        integer capacity
    }
    ticket_order {
        bigint order_id PK
        text customer_email
        timestamptz placed_at
        text payment_status
    }
    ticket {
        bigint ticket_id PK
        bigint order_id FK
        bigint event_id FK
        text seat_label "Optional"
        numeric price
        text status
        timestamptz issued_at
    }
    venue ||--o{ event : "venue_id"
    ticket_order ||--o{ ticket : "order_id"
    event ||--o{ ticket : "event_id"
```

PK identifies a record; FK links to another table; UK marks a single-field unique value. The relationship ends show exactly one, zero or one, or zero or many records. Composite unique keys and conditional rules are listed in the schema and design.

[Diagram image](../images/ndianekwu_Chibuzor_301893177_ERDiagram.png)
