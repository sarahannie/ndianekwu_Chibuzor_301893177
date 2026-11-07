// Run once in mongosh against a fresh exercise database.
// These records are fictional events for the case study.
(async function () {
  db = db.getSiblingDB('portfolio_nosql');
  if ((await db.getCollectionNames()).includes("ticket_events")) {
    throw new Error('The exercise collection already exists. Use a fresh database.');
  }

  // The validator checks the stable event fields while details can vary.
  await db.createCollection("ticket_events", {
    validator: {
    "$jsonSchema": {
        "bsonType": "object",
        "required": [
            "_id",
            "schemaVersion",
            "simulation",
            "eventType",
            "occurredAt",
            "source",
            "embedded",
            "references",
            "details"
        ],
        "properties": {
            "_id": {
                "bsonType": "string",
                "minLength": 1
            },
            "schemaVersion": {
                "enum": [
                    1
                ]
            },
            "simulation": {
                "enum": [
                    true
                ]
            },
            "eventType": {
                "bsonType": "string",
                "enum": [
                    "order_placed",
                    "ticket_issued"
                ]
            },
            "occurredAt": {
                "bsonType": "date"
            },
            "source": {
                "bsonType": "object",
                "required": [
                    "entity",
                    "key",
                    "snapshot"
                ],
                "properties": {
                    "entity": {
                        "enum": [
                            "ticket"
                        ]
                    },
                    "key": {
                        "bsonType": "object",
                        "required": [
                            "ticket_id"
                        ]
                    },
                    "snapshot": {
                        "bsonType": "object"
                    }
                }
            },
            "embedded": {
                "bsonType": "object"
            },
            "references": {
                "bsonType": "object"
            },
            "details": {
                "bsonType": "object"
            }
        }
    }
},
    validationLevel: 'strict', validationAction: 'error'
  });

  // Insert the four example events and show their IDs.
  printjson(await db.getCollection("ticket_events").insertMany([
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
    },
    {
        "_id": "event_000002",
        "schemaVersion": 1,
        "simulation": true,
        "eventType": "ticket_issued",
        "occurredAt": ISODate("2030-01-01T10:01:00Z"),
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
            "channel": "mobile",
            "note": "Illustrative event-specific metadata",
            "attributes": [
                {
                    "entity": "ticket",
                    "key": {
                        "ticket_id": 400
                    },
                    "field": "seat_label",
                    "value": "A1"
                }
            ],
            "examples": {
                "payment_reference": "illustrative payment_reference"
            }
        }
    }
]));
  await db.getCollection("ticket_events").createIndex({eventType: 1, occurredAt: -1}, {name: 'event_type_time'});

  // 1. Find the first sample event type (up to five documents).
  printjson(await db.getCollection("ticket_events").find({"eventType":"order_placed"}).sort({_id:1}).limit(5).toArray());

  // 2. Find events for the first source record using nested key fields (up to five).
  printjson(await db.getCollection("ticket_events").find({"source.key.ticket_id":400}).sort({_id:1}).limit(5).toArray());

  // 3. Find events in the sample time range using a MongoDB Date filter (up to five).
  printjson(await db.getCollection("ticket_events").find({"occurredAt":{"$gte":ISODate("2030-01-01T10:00:00Z"), "$lt":ISODate("2030-01-01T11:00:00Z")}}).sort({_id:1}).limit(5).toArray());

  // 4. Count documents for each event type.
  printjson(await db.getCollection("ticket_events").aggregate([{"$group":{"_id":"$eventType", "documentCount":{"$sum":1}}}, {"$sort":{"_id":1}}]).toArray());

  // A date stored as text should be rejected by the validator.
  try {
    await db.getCollection("ticket_events").insertOne({...{
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
}, _id: 'invalid_date_example', occurredAt: 'not-a-date'});
  } catch (error) { print('Invalid date error: ' + error.code); }

  // Reusing an event ID should be rejected by the unique _id index.
  try { await db.getCollection("ticket_events").insertOne({
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
}); }
  catch (error) { print('Duplicate ID error: ' + error.code); }

  print('Document count: ' + await db.getCollection("ticket_events").countDocuments());
})().catch(error => { print(error.stack || String(error)); quit(1); });
