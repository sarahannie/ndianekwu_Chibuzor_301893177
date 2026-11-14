#!/usr/bin/env bash
# Runs the two-buyer test three ways. Session B always starts one second after Session A.
# Usage:  ./Ndianekwu_Chibuzor_301893177_P3_RunConcurrency.sh "<psql connection options>"
# Example: ./Ndianekwu_Chibuzor_301893177_P3_RunConcurrency.sh "-d ticketing"
set -u
PSQL="psql -X -q $1"
P=Ndianekwu_Chibuzor_301893177
cd "$(dirname "$0")"

state() {
  $PSQL -c "SELECT e.capacity, count(t.ticket_id) AS tickets_issued,
                   CASE WHEN count(t.ticket_id) > e.capacity THEN 'OVERSOLD' ELSE 'ok' END AS result
            FROM portfolio.event e
            LEFT JOIN portfolio.ticket t ON t.event_id = e.event_id AND t.status <> 'cancelled'
            WHERE e.event_id = 204 GROUP BY e.capacity;"
}
reset() {
  $PSQL -c "DELETE FROM portfolio.ticket WHERE ticket_id IN (460, 461);
            DELETE FROM portfolio.ticket_order WHERE order_id IN (360, 361);"
}
two_buyers() {   # $1 = script, $2 = isolation level
  $PSQL -v iso="$2" -v who=SessionA -v order_id=360 -v ticket_id=460 -v customer_id=6 -v pause=3 -f "$1" > /tmp/p3_a.log 2>&1 &
  sleep 1
  $PSQL -v iso="$2" -v who=SessionB -v order_id=361 -v ticket_id=461 -v customer_id=7 -v pause=0 -f "$1" > /tmp/p3_b.log 2>&1 &
  wait
  echo "----- Session A output"; cat /tmp/p3_a.log
  echo "----- Session B output"; cat /tmp/p3_b.log
}

echo "##### Starting state of event 204"; state

echo; echo "##### TEST 1: READ COMMITTED, check then insert, no lock"
two_buyers ${P}_P3_BuyLastTicket_NoLock.sql "READ COMMITTED"
echo "----- State after test 1"; state; reset

echo; echo "##### TEST 2: READ COMMITTED with SELECT ... FOR UPDATE on the event row"
two_buyers ${P}_P3_BuyLastTicket_RowLock.sql "READ COMMITTED"
echo "----- State after test 2"; state; reset

echo; echo "##### TEST 3: SERIALIZABLE, check then insert, no explicit lock"
two_buyers ${P}_P3_BuyLastTicket_NoLock.sql "SERIALIZABLE"
echo "----- State after test 3"; state; reset
