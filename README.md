# Fattoush MVP

Fattoush is a multi-app grocery delivery MVP built for three roles:

- Customer app
- Admin panel
- Driver operations

This repository currently contains:

- A Flutter customer app with admin capabilities for local MVP testing
- A NestJS backend with Prisma and PostgreSQL

## Project Structure

```text
1-mvp-3-backend-login-checkout/
├── api/                 # NestJS backend + Prisma
└── apps/
    └── customer_app/    # Flutter mobile app
```

## Main Features

- Browse products as guest
- Register and login as customer or admin
- Cart and checkout flow
- Cash on delivery and card UI flow
- Orders saved to PostgreSQL
- Customer order history
- Admin product management
- Admin order status management
- Product image picking from phone gallery

## Tech Stack

- Flutter
- NestJS
- Prisma
- PostgreSQL
- JWT authentication

## Local Development

### 1. Backend

See the backend setup guide in:

- [api/README.md](C:\Users\RTX\Documents\Codex\2026-04-30\1-mvp-3-backend-login-checkout\api\README.md)

### 2. Flutter app

See the mobile app setup guide in:

- [apps/customer_app/README.md](C:\Users\RTX\Documents\Codex\2026-04-30\1-mvp-3-backend-login-checkout\apps\customer_app\README.md)

## Demo Accounts

Current local demo accounts:

- Admin: `admin@fattoush.app`
- Customer: `customer@fattoush.app`
- Driver: `driver@fattoush.app`

Passwords are intentionally not stored in the repository. Set `SEED_DEMO_PASSWORD` locally before seeding.

## Notes

- This repository is prepared for local development and MVP iteration.
- Secrets are intentionally excluded from source control.
- Uploaded product images are stored locally during development and are excluded from Git.
- Before production deployment, restrict `CORS_ORIGINS`, use a strong `JWT_SECRET`, and disable Swagger unless needed.
