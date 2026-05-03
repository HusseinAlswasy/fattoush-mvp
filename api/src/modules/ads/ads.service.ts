import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AdsService {
  constructor(private readonly prisma: PrismaService) {}

  getAds() {
    return this.prisma.adsBanner.findMany({
      where: { isActive: true },
      orderBy: { createdAt: 'desc' },
    });
  }
}
