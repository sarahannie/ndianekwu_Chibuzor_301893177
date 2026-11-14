// Portfolio 4: ticket activity log for the Event Ticketing Platform (MongoDB, document model).
// Run in mongosh:  mongosh "<connection string>" --file Ndianekwu_Chibuzor_301893177_P4_MongoDB.js
// The script drops and rebuilds its own database (portfolio_nosql), so it can be run again safely.

db = db.getSiblingDB("portfolio_nosql");
db.dropDatabase();

// 1. Collection with a validator. Common fields are fixed; "details" is free to differ per event type.
db.createCollection("ticket_events", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "eventType", "occurredAt", "order", "event"],
      properties: {
        _id: { bsonType: "string" },
        eventType: { enum: ["order_placed", "ticket_issued", "ticket_scanned", "order_refunded"] },
        occurredAt: { bsonType: "date" },
        order: {
          bsonType: "object",
          required: ["order_id", "customer"],
          properties: {
            order_id: { bsonType: ["int", "long"] },
            customer: {
              bsonType: "object",
              required: ["customer_id", "full_name"]
            }
          }
        },
        event: {
          bsonType: "object",
          required: ["event_id", "title"],
          properties: { event_id: { bsonType: ["int", "long"] } }
        },
        tickets: { bsonType: "array" },
        details: { bsonType: "object" }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// 2. Sample documents. IDs, names and prices match the PostgreSQL sample data (orders 300, 302, 315).
// Customer, event and venue details are embedded as they were at the time of the activity.
const jazz = { event_id: NumberInt(200), title: "Lagos Jazz Night", starts_at: ISODate("2026-12-10T18:00:00Z"),
               venue: { venue_id: NumberInt(100), name: "Harbour Hall", city: "Lagos" } };
const afro = { event_id: NumberInt(202), title: "Afrobeats Live", starts_at: ISODate("2026-12-20T17:00:00Z"),
               venue: { venue_id: NumberInt(101), name: "Garden Arena", city: "Abuja" } };
const fair = { event_id: NumberInt(207), title: "Harmattan Food Fair", starts_at: ISODate("2026-12-28T11:00:00Z"),
               venue: { venue_id: NumberInt(102), name: "Riverside Pavilion", city: "Port Harcourt" } };
const adaeze = { customer_id: NumberInt(1), full_name: "Adaeze Okonkwo", email: "adaeze.okonkwo@example.test" };
const ngozi  = { customer_id: NumberInt(3), full_name: "Ngozi Eze", email: "ngozi.eze@example.test" };
const ibrahim = { customer_id: NumberInt(4), full_name: "Ibrahim Musa", email: "ibrahim.musa@example.test" };

const inserted = db.ticket_events.insertMany([
  { _id: "evt-0001", eventType: "order_placed", occurredAt: ISODate("2026-11-01T08:00:00Z"),
    order: { order_id: NumberInt(300), customer: adaeze }, event: jazz,
    details: { channel: "web", payment: { method: "card", amount_naira: 30000 } } },

  { _id: "evt-0002", eventType: "ticket_issued", occurredAt: ISODate("2026-11-01T08:05:00Z"),
    order: { order_id: NumberInt(300), customer: adaeze }, event: jazz,
    tickets: [ { ticket_id: NumberInt(400), seat_label: "A1", price_naira: 15000 },
               { ticket_id: NumberInt(401), seat_label: "A2", price_naira: 15000 } ],
    details: { delivery: "email" } },

  { _id: "evt-0003", eventType: "order_placed", occurredAt: ISODate("2026-11-03T10:14:00Z"),
    order: { order_id: NumberInt(302), customer: ngozi }, event: afro,
    details: { channel: "mobile_app", payment: { method: "bank_transfer", amount_naira: 100000 }, promo_code: "DETTY26" } },

  { _id: "evt-0004", eventType: "ticket_issued", occurredAt: ISODate("2026-11-03T10:19:00Z"),
    order: { order_id: NumberInt(302), customer: ngozi }, event: afro,
    tickets: [ { ticket_id: NumberInt(403), price_naira: 25000 }, { ticket_id: NumberInt(404), price_naira: 25000 },
               { ticket_id: NumberInt(405), price_naira: 25000 }, { ticket_id: NumberInt(406), price_naira: 25000 } ],
    details: { delivery: "in_app" } },

  { _id: "evt-0005", eventType: "ticket_scanned", occurredAt: ISODate("2026-12-10T17:42:00Z"),
    order: { order_id: NumberInt(300), customer: adaeze }, event: jazz,
    tickets: [ { ticket_id: NumberInt(400), seat_label: "A1" } ],
    details: { gate: "North entrance", device: "scanner-07", staff: "usher-12" } },

  { _id: "evt-0006", eventType: "order_refunded", occurredAt: ISODate("2026-11-20T09:30:00Z"),
    order: { order_id: NumberInt(315), customer: ibrahim }, event: fair,
    details: { reason: "event cancelled", refund: { amount_naira: 12000, method: "original payment" } } }
]);
print("Inserted documents: " + Object.keys(inserted.insertedIds).length);

// 3. Indexes for the two main ways the log is read.
db.ticket_events.createIndex({ "order.order_id": 1, occurredAt: 1 }, { name: "order_timeline" });
db.ticket_events.createIndex({ eventType: 1, occurredAt: -1 }, { name: "type_recent_first" });

// 4. Queries
print("\n--- Q1. Full timeline of order 300 (one collection, no joins)");
printjson(db.ticket_events.find({ "order.order_id": 300 },
  { eventType: 1, occurredAt: 1, "event.title": 1, tickets: 1 }).sort({ occurredAt: 1 }).toArray());

print("\n--- Q2. Activity in November 2026, newest first");
printjson(db.ticket_events.find(
  { occurredAt: { $gte: ISODate("2026-11-01T00:00:00Z"), $lt: ISODate("2026-12-01T00:00:00Z") } },
  { eventType: 1, occurredAt: 1, "order.order_id": 1 }).sort({ occurredAt: -1 }).toArray());

print("\n--- Q3. Events that involve seat A1 (match inside the embedded tickets array)");
printjson(db.ticket_events.find({ tickets: { $elemMatch: { seat_label: "A1" } } },
  { eventType: 1, "event.title": 1 }).toArray());

print("\n--- Q4. Tickets issued and value per event (aggregation pipeline)");
printjson(db.ticket_events.aggregate([
  { $match: { eventType: "ticket_issued" } },
  { $unwind: "$tickets" },
  { $group: { _id: "$event.title", tickets: { $sum: 1 }, value_naira: { $sum: "$tickets.price_naira" } } },
  { $sort: { value_naira: -1 } }
]).toArray());

print("\n--- Q5. Number of documents per event type");
printjson(db.ticket_events.aggregate([
  { $group: { _id: "$eventType", documents: { $sum: 1 } } }, { $sort: { _id: 1 } }
]).toArray());

print("\n--- Q6. Does Q1 use the order_timeline index? (winning plan stage and documents examined)");
const plan = db.ticket_events.find({ "order.order_id": 300 }).sort({ occurredAt: 1 }).explain("executionStats");
printjson({ winningPlan: plan.queryPlanner.winningPlan,
            returned: plan.executionStats.nReturned,
            docsExamined: plan.executionStats.totalDocsExamined });

// 5. Validation tests: both inserts must fail.
print("\n--- V1. occurredAt stored as text instead of a date (expect error code 121)");
try {
  db.ticket_events.insertOne({ _id: "evt-bad-1", eventType: "order_placed", occurredAt: "2026-11-05",
    order: { order_id: NumberInt(301), customer: { customer_id: NumberInt(2), full_name: "Tunde Bakare" } }, event: jazz });
  print("NOT REJECTED");
} catch (e) { print("Rejected with code " + e.code); }

print("\n--- V2. unknown event type (expect error code 121)");
try {
  db.ticket_events.insertOne({ _id: "evt-bad-2", eventType: "ticket_lost", occurredAt: new Date(),
    order: { order_id: NumberInt(301), customer: { customer_id: NumberInt(2), full_name: "Tunde Bakare" } }, event: jazz });
  print("NOT REJECTED");
} catch (e) { print("Rejected with code " + e.code); }

print("\n--- V3. repeated _id (expect error code 11000)");
try {
  db.ticket_events.insertOne({ _id: "evt-0001", eventType: "order_placed", occurredAt: new Date(),
    order: { order_id: NumberInt(300), customer: adaeze }, event: jazz });
  print("NOT REJECTED");
} catch (e) { print("Rejected with code " + e.code); }

print("\nDocuments in collection after the tests: " + db.ticket_events.countDocuments());
