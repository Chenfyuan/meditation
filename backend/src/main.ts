import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableShutdownHooks();
  app.enableCors({
    origin: resolveCorsOrigins(process.env.CORS_ORIGIN),
  });

  const port = Number(process.env.PORT ?? 3000);
  await app.listen(port, '0.0.0.0');

  Logger.log(`Meditation backend listening on ${await app.getUrl()}`);
}

bootstrap();

function resolveCorsOrigins(corsOrigin: string | undefined): true | string[] {
  if (!corsOrigin || corsOrigin.trim() === '' || corsOrigin.trim() === '*') {
    return true;
  }

  return corsOrigin
    .split(',')
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0);
}
