# Deploy Fattoush API on Vercel

## What Vercel will host

Vercel will host the NestJS API so you do not need to run `npm run start:dev`
on your PC every time.

## Required cloud services

The local PostgreSQL database on your PC will not work from Vercel. Create a
cloud PostgreSQL database first, for example Neon, Supabase, or Railway, then
copy its PostgreSQL connection string.

Uploaded files in `uploads/` are local-only. For production product images,
use Cloudinary or S3 and store only the image URL in the database.

## Vercel project settings

When importing the GitHub repository in Vercel:

- Root Directory: `api`
- Framework Preset: `Other`
- Build Command: keep default or `npm run build`
- Install Command: keep default

## Environment variables

Add these variables in Vercel Project Settings -> Environment Variables:

```env
DATABASE_URL="postgresql://USER:PASSWORD@HOST:PORT/DATABASE?sslmode=require"
JWT_SECRET="use_a_long_random_secret_here"
JWT_EXPIRES_IN="7d"
ENABLE_SWAGGER="true"
CORS_ORIGINS=""
NODE_ENV="production"
```

For the first deployment, keep `ENABLE_SWAGGER=true` so you can open:

```text
https://YOUR-VERCEL-PROJECT.vercel.app/docs
```

## Push database schema

After creating the cloud database, run this once locally from the `api` folder
with the cloud `DATABASE_URL`:

```powershell
$env:DATABASE_URL="postgresql://USER:PASSWORD@HOST:PORT/DATABASE?sslmode=require"
npx prisma db push
npx prisma db seed
```

## Test URLs

After deployment, test:

```text
https://YOUR-VERCEL-PROJECT.vercel.app/api/products
https://YOUR-VERCEL-PROJECT.vercel.app/docs
```

## Mobile app

After Vercel works, update the Flutter API base URL to:

```text
https://YOUR-VERCEL-PROJECT.vercel.app
```

Then rebuild the app.
