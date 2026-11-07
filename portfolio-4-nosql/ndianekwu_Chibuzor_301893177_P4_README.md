# Portfolio 4 — NoSQL and Advanced Data Models

I used MongoDB collection ticket_events for order_placed and ticket_issued events. These are fictional event examples based on ticket, event, ticket_order.

## Document model

| Field | Meaning |
| --- | --- |
| _id | Unique string event ID |
| eventType | One of the two selected case event labels |
| occurredAt | Native BSON Date; sample timestamps are in 2030 |
| source | Original entity, primary key and saved JSON snapshot |
| embedded | Linked record snapshots read with the event |
| references | Keys for linked sources kept outside the embedded snapshots |
| details | Event metadata whose fields vary |

Related event details are stored as snapshots with the event. This makes an event readable in one document. It duplicates some information, and later SQL changes do not automatically update the snapshots. PostgreSQL continues to enforce the relational rules.

## Example document

```javascript
{
    "_id": "event_000001",
    "schemaVersion": 1,
    "simulation": true,
    "eventType": "order_placed",
    "occurredAt": ISODate("2030-01-01T10:00:00Z"),
    "source": {
        "entity": "ticket",
        "key": {
            "ticket_id": 400
        },
        "snapshot": {
            "ticket_id": 400,
            "order_id": 300,
            "event_id": 200,
            "seat_label": "A1",
            "price": 45,
            "status": "issued",
            "issued_at": "2026-11-07T18:05:00Z"
        }
    },
    "embedded": {
        "event": [
            {
                "key": {
                    "event_id": 200
                },
                "snapshot": {
                    "event_id": 200,
                    "venue_id": 100,
                    "title": "Synthetic Jazz Night",
                    "starts_at": "2026-12-10T19:00:00Z",
                    "status": "scheduled",
                    "capacity": 300
                },
                "via": [
                    "ticket.event_id → event"
                ]
            }
        ]
    },
    "references": {
        "ticket_order": [
            {
                "key": {
                    "order_id": 300
                },
                "via": [
                    "ticket.order_id → ticket_order"
                ]
            }
        ]
    },
    "details": {
        "channel": "web"
    }
}
```

## Queries and results

| Query | Returned documents |
| --- | --- |
| Find the first sample event type (up to five documents). | 1 |
| Find events for the first source record using nested key fields (up to five). | 2 |
| Find events in the sample time range using a MongoDB Date filter (up to five). | 2 |
| Count documents for each event type. | 2 |

## 1. Find the first sample event type (up to five documents).

```javascript
db.getCollection("ticket_events").find({"eventType":"order_placed"}).sort({_id:1}).limit(5).toArray();
```

Selected fields from the returned documents:

```json
[
  {
    "_id": "event_000001",
    "eventType": "order_placed",
    "occurredAt": {
      "$date": "2030-01-01T10:00:00Z"
    },
    "source": {
      "ticket_id": 400
    }
  }
]
```

## 2. Find events for the first source record using nested key fields (up to five).

```javascript
db.getCollection("ticket_events").find({"source.key.ticket_id":400}).sort({_id:1}).limit(5).toArray();
```

Selected fields from the returned documents:

```json
[
  {
    "_id": "event_000001",
    "eventType": "order_placed",
    "occurredAt": {
      "$date": "2030-01-01T10:00:00Z"
    },
    "source": {
      "ticket_id": 400
    }
  },
  {
    "_id": "event_000002",
    "eventType": "ticket_issued",
    "occurredAt": {
      "$date": "2030-01-01T10:01:00Z"
    },
    "source": {
      "ticket_id": 400
    }
  }
]
```

## 3. Find events in the sample time range using a MongoDB Date filter (up to five).

```javascript
db.getCollection("ticket_events").find({"occurredAt":{"$gte":ISODate("2030-01-01T10:00:00Z"), "$lt":ISODate("2030-01-01T11:00:00Z")}}).sort({_id:1}).limit(5).toArray();
```

Selected fields from the returned documents:

```json
[
  {
    "_id": "event_000001",
    "eventType": "order_placed",
    "occurredAt": {
      "$date": "2030-01-01T10:00:00Z"
    },
    "source": {
      "ticket_id": 400
    }
  },
  {
    "_id": "event_000002",
    "eventType": "ticket_issued",
    "occurredAt": {
      "$date": "2030-01-01T10:01:00Z"
    },
    "source": {
      "ticket_id": 400
    }
  }
]
```

## 4. Count documents for each event type.

```javascript
db.getCollection("ticket_events").aggregate([{"$group":{"_id":"$eventType", "documentCount":{"$sum":1}}}, {"$sort":{"_id":1}}]).toArray();
```

| _id | documentCount |
| --- | --- |
| order_placed | 1 |
| ticket_issued | 1 |

## Validation and suitability

MongoDB inserted 2 documents. An invalid date type was rejected with code 121 and a repeated event ID with 11000. The collection still contained 2 valid documents. The compound eventType/occurredAt index supports those access fields; this exercise does not measure its speed.

The details field can vary across event types, while the common fields have a validator. Events can be added as separate documents rather than growing one large history record.

## Run the script

Connect mongosh to a fresh exercise database and run ndianekwu_Chibuzor_301893177_P4_MongoDB.js. It selects portfolio_nosql, creates the collection, inserts the sample documents and displays the query results. [Implementation evidence](screenshots/ndianekwu_Chibuzor_301893177_P4_DocumentsAndQueries.png).

## References

- [MongoDB — data modelling](https://www.mongodb.com/docs/manual/data-modeling/)

