import { Injectable } from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { OrdersService } from '../orders/orders.service';
import { DriverStatusUpdateDto } from './dto/driver-status-update.dto';

@Injectable()
export class DriverService {
  constructor(
    private readonly ordersService: OrdersService,
    private readonly prisma: PrismaService,
  ) {}

  getDriverOrders(driverId: string) {
    return this.ordersService.getDriverOrders(driverId);
  }

  acceptDriverOrder(orderId: string, driverId: string) {
    return this.ordersService.acceptDriverOrder(orderId, driverId);
  }

  async updateDriverOrderStatus(orderId: string, driverId: string, dto: DriverStatusUpdateDto) {
    if (dto.lat !== undefined && dto.lng !== undefined) {
      await this.prisma.driverLocation.upsert({
        where: { driverId },
        update: { lat: dto.lat, lng: dto.lng },
        create: { driverId, lat: dto.lat, lng: dto.lng },
      });
    }

    return this.ordersService.updateDriverOrderStatus(
      orderId,
      driverId,
      dto.status as OrderStatus,
    );
  }
}
