# Fattoush Backend

NestJS + Prisma + PostgreSQL backend for the Fattoush grocery delivery MVP.

## Implemented Areas

- JWT authentication
- Public products and ads
- Favorites
- Order creation
- Customer order history
- Admin product management
- Admin order management and status updates
- Driver order flow
- Swagger API documentation
- Local product image uploads for development

## Local Setup

1. Copy the example environment file:

```powershell
Copy-Item .env.example .env
```

2. Update `.env` with your local database settings:

```env
PORT=3000
DATABASE_URL="postgresql://postgres:your_strong_db_password@localhost:5432/fattoush_mvp?schema=public"
JWT_SECRET="replace_with_a_long_random_secret"
JWT_EXPIRES_IN="7d"
ENABLE_SWAGGER="true"
CORS_ORIGINS="http://localhost:3000,http://127.0.0.1:3000"
SEED_DEMO_PASSWORD="ChangeMeBeforeSeeding!"
```

3. Install packages:

```powershell
npm.cmd install
```

4. Generate Prisma client:

```powershell
npm.cmd run prisma:generate
```

5. Sync or migrate the database:

```powershell
npm.cmd run prisma:migrate -- --name init
```

6. Seed sample data:

```powershell
npm.cmd run prisma:seed
```

7. Start the API:

```powershell
npm.cmd run start
```

For development watch mode:

```powershell
npm.cmd run start:dev
```

## Default Local URLs

- API base: `http://localhost:3000/api`
- Swagger: `http://localhost:3000/docs`

## Main Endpoints

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `GET /api/products`
- `GET /api/products/:id`
- `POST /api/orders`
- `GET /api/customer/orders`
- `GET /api/admin/products`
- `POST /api/admin/products`
- `POST /api/admin/products/upload-image`
- `GET /api/admin/orders`
- `POST /api/admin/orders/:id/status`
- `GET /api/driver/orders`

## Security Notes

- Environment secrets are not committed.
- `JWT_SECRET` must be replaced with a strong value before production.
- Swagger should be disabled in production unless explicitly needed.
- `CORS_ORIGINS` should contain only your trusted app domains.
- Uploaded images are stored in the local `uploads/` folder during development.
- Payment gateway, notifications, and production media storage still need production integration.
