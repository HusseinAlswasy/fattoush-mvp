import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class FavoritesService {
  constructor(private readonly prisma: PrismaService) {}

  getFavorites(userId: string) {
    return this.prisma.favorite.findMany({
      where: { userId },
      include: { product: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  addFavorite(userId: string, productId: string) {
    return this.prisma.favorite.upsert({
      where: { userId_productId: { userId, productId } },
      update: {},
      create: { userId, productId },
      include: { product: true },
    });
  }

  async removeFavorite(userId: string, productId: string) {
    await this.prisma.favorite.deleteMany({
      where: { userId, productId },
    });

    return { success: true };
  }
}
