import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { existsSync, mkdirSync } from 'fs';
import { join } from 'path';
import { AppModule } from './app.module';

async function bootstrap() {
  const isProduction = process.env.NODE_ENV === 'production';
  const jwtSecret = process.env.JWT_SECRET;

  if (!jwtSecret || jwtSecret === 'super-secret-change-me') {
    throw new Error('JWT_SECRET must be set to a strong non-default value.');
  }

  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  const uploadsPath = join(process.cwd(), 'uploads');
  if (!existsSync(uploadsPath)) {
    mkdirSync(uploadsPath, { recursive: true });
  }

  const allowedOrigins = (process.env.CORS_ORIGINS ?? '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);

  app.enableCors({
    origin: (origin, callback) => {
      if (!origin) {
        return callback(null, true);
      }

      if (!isProduction && allowedOrigins.length === 0) {
        return callback(null, true);
      }

      if (allowedOrigins.includes(origin)) {
        return callback(null, true);
      }

      return callback(new Error('CORS origin is not allowed.'), false);
    },
    credentials: true,
  });
  app.useStaticAssets(uploadsPath, {
    prefix: '/uploads/',
  });
  app.setGlobalPrefix('api');
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );

  const enableSwagger = process.env.ENABLE_SWAGGER === 'true' || !isProduction;
  if (enableSwagger) {
    const swaggerConfig = new DocumentBuilder()
      .setTitle('Fattoush MVP API')
      .setDescription('Backend APIs for customer, admin, and driver applications.')
      .setVersion('1.0.0')
      .addBearerAuth()
      .build();

    const swaggerDocument = SwaggerModule.createDocument(app, swaggerConfig);
    SwaggerModule.setup('docs', app, swaggerDocument);
  }

  await app.listen(process.env.PORT ?? 3000, '0.0.0.0');
}
bootstrap();
