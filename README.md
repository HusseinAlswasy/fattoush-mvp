# Fattoush MVP

Fattoush supermarket MVP with Flutter mobile app and NestJS backend for customer, admin, and delivery workflows.

## Overview

Fattoush is a multi-app grocery delivery MVP built around three roles:

- Customer
- Admin
- Driver

This repository currently includes:

- A Flutter mobile app used for customer flows and local admin testing
- A NestJS backend with Prisma and PostgreSQL

## Project Structure

```text
.
├── api/                 # NestJS backend + Prisma
└── apps/
    └── customer_app/    # Flutter mobile app
```

## Main Features

- Browse products as guest
- Register and login as customer or admin
- Cart and checkout flow
- Cash on delivery and card payment UI flow
- Orders stored in PostgreSQL
- Customer order history
- Admin product management
- Admin order status updates
- Local image upload during development

## Tech Stack

- Flutter
- NestJS
- Prisma
- PostgreSQL
- JWT authentication

## Local Development

### Backend

See:

- [api/README.md](api/README.md)

### Mobile App

See:

- [apps/customer_app/README.md](apps/customer_app/README.md)

## Demo Accounts

Current local demo accounts:

- Admin: `admin@fattoush.app`
- Customer: `customer@fattoush.app`
- Driver: `driver@fattoush.app`

Passwords are intentionally not stored in the repository. Set `SEED_DEMO_PASSWORD` locally before seeding.

## Security Notes

- Secrets are intentionally excluded from source control.
- Uploaded product images are stored locally during development and are excluded from Git.
- Before production deployment, restrict `CORS_ORIGINS`, use a strong `JWT_SECRET`, and disable Swagger unless needed.
