# Data Model: mycoolapp

**Status**: Minimal (simple LAMP app)

## Overview

mycoolapp uses a single MySQL 8.0 schema for application data. A detailed entity model will be added once functional requirements are finalized.

## Schema

- **Database**: `mycoolapp`
- **Engine**: InnoDB
- **Charset**: utf8mb4

## Entities

- **TBD**: Application-specific tables are not yet defined.

## Constraints & Rules

- Encryption at rest via managed disk encryption
- TLS 1.2+ required for database connections
- Daily logical backups (retention 7 days)
