import type { Request, Response } from 'express';
import { createNestApp } from '../src/bootstrap';

let cachedServer: ((req: Request, res: Response) => void) | null = null;

export default async function handler(req: Request, res: Response) {
  if (!cachedServer) {
    const app = await createNestApp();
    await app.init();
    cachedServer = app.getHttpAdapter().getInstance();
  }

  return cachedServer(req, res);
}
