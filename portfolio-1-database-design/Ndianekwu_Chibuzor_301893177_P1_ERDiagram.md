# Event Ticketing Platform: ER diagram

![ER diagram](../images/Ndianekwu_Chibuzor_301893177_ERDiagram.png)

The same model in Mermaid (GitHub renders it):

```mermaid
erDiagram
    customer ||--o{ ticket_order : places
    ticket_order ||--o{ ticket : contains
    venue ||--o{ event : hosts
    event ||--o{ ticket : sells
    customer {
        bigint customer_id PK
        text full_name
        text email UK
        text phone "optional"
    }
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
        bigint customer_id FK
        timestamptz placed_at
        text payment_status
    }
    ticket {
        bigint ticket_id PK
        bigint order_id FK
        bigint event_id FK
        text seat_label "optional"
        numeric price
        text status
        timestamptz issued_at
    }
```

Reading the lines: `||` is exactly one, `o{` is zero or many. A customer can have no orders yet; an order always belongs to exactly one customer.

The PNG was drawn with Graphviz from the same table list.
