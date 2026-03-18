# Q1 Business Resilience Review — 2026-03-17
Attendees: Alice (CTO), Bob (Platform Lead), Carol (Business Continuity Lead)

Alice: We need to formally define our disaster recovery strategy.
       Recovery Point Objective should be 4 hours and Recovery Time Objective 8 hours.

Bob: We should also require that all tier-1 services have a validated failover runbook
     before going to production. That runbook needs to be reviewed quarterly.

Carol: Agreed. And we need an owner assigned to each failover path,
       separate from the normal on-call rotation.

Alice: Let's also revisit our cost governance for reserved instances.
       We're paying for capacity we don't use and should set a quarterly right-sizing review.
