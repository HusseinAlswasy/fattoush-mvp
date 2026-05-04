import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import {
  OrderStatus,
  PaymentProvider,
  PaymentStatus,
  Prisma,
  type Order,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateOrderDto } from './dto/create-order.dto';

@Injectable()
export class OrdersService {
  constructor(private readonly prisma: PrismaService) {}

  async createOrder(userId: string, dto: CreateOrderDto) {
    const productIds = dto.items.map((item) => item.productId);
    const products = await this.prisma.product.findMany({
      where: { id: { in: productIds }, isActive: true },
    });

    if (products.length !== productIds.length) {
      throw new BadRequestException('One or more products are invalid.');
    }

    const productMap = new Map(products.map((product) => [product.id, product]));
    const subtotal = dto.items.reduce((sum, item) => {
      const product = productMap.get(item.productId)!;
      return sum + Number(product.price) * item.quantity;
    }, 0);

    const deliveryFee = subtotal >= 100 ? 0 : 10;
    const total = subtotal + deliveryFee;

    return this.prisma.$transaction(async (tx) => {
      const order = await tx.order.create({
        data: {
          userId,
          status: OrderStatus.PENDING,
          paymentMethod: dto.paymentMethod,
          paymentStatus:
            dto.paymentMethod === 'COD' ? PaymentStatus.UNPAID : PaymentStatus.UNPAID,
          subtotal,
          deliveryFee,
          total,
          addressText: dto.addressText,
          lat: dto.lat,
          lng: dto.lng,
          items: {
            create: dto.items.map((item) => {
              const product = productMap.get(item.productId)!;
              const unitPrice = Number(product.price);
              return {
                productId: item.productId,
                unitPrice,
                quantity: item.quantity,
                lineTotal: unitPrice * item.quantity,
              };
            }),
          },
        },
        include: {
          items: { include: { product: true } },
        },
      });

      await tx.payment.create({
        data: {
          orderId: order.id,
          provider: dto.paymentMethod === 'COD' ? PaymentProvider.CASH : PaymentProvider.STRIPE,
          amount: total,
          status: dto.paymentMethod === 'COD' ? PaymentStatus.UNPAID : PaymentStatus.UNPAID,
        },
      });

      return order;
    });
  }

  getCustomerOrders(userId: string) {
    return this.prisma.order.findMany({
      where: { userId },
      include: {
        items: { include: { product: true } },
        assignedDriver: { select: { id: true, name: true, phone: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getCustomerOrderById(userId: string, id: string) {
    const order = await this.prisma.order.findFirst({
      where: { id, userId },
      include: {
        items: { include: { product: true } },
        assignedDriver: { select: { id: true, name: true, phone: true } },
        payments: true,
      },
    });

    if (!order) {
      throw new NotFoundException('Order not found.');
    }

    return order;
  }

  async assignDriver(orderId: string, driverId: string) {
    const order = await this.findOrderById(orderId);
    await this.prisma.user.findFirstOrThrow({
      where: { id: driverId, role: 'DRIVER' },
    });

    return this.prisma.order.update({
      where: { id: order.id },
      data: {
        assignedDriverId: driverId,
        status: OrderStatus.ASSIGNED,
      },
    });
  }

  getAllOrders() {
    return this.prisma.order.findMany({
      include: {
        user: { select: { id: true, name: true, email: true, phone: true } },
        assignedDriver: { select: { id: true, name: true, email: true, phone: true } },
        items: { include: { product: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  getDrivers() {
    return this.prisma.user.findMany({
      where: { role: 'DRIVER' },
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        createdAt: true,
      },
      orderBy: { createdAt: 'asc' },
    });
  }

  async getOrderById(id: string) {
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: {
        user: { select: { id: true, name: true, email: true, phone: true } },
        assignedDriver: { select: { id: true, name: true, email: true, phone: true } },
        items: { include: { product: true } },
        payments: true,
      },
    });

    if (!order) {
      throw new NotFoundException('Order not found.');
    }

    return order;
  }

  getDriverOrders(driverId: string) {
    return this.prisma.order.findMany({
      where: { assignedDriverId: driverId },
      include: {
        user: { select: { id: true, name: true, phone: true } },
        items: { include: { product: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async acceptDriverOrder(orderId: string, driverId: string) {
    const order = await this.getAssignedDriverOrder(orderId, driverId);
    if (order.status !== OrderStatus.ASSIGNED) {
      throw new BadRequestException('Order cannot be accepted in its current state.');
    }

    return this.prisma.order.update({
      where: { id: order.id },
      data: { status: OrderStatus.CONFIRMED },
    });
  }

  async updateDriverOrderStatus(orderId: string, driverId: string, status: OrderStatus) {
    const order = await this.getAssignedDriverOrder(orderId, driverId);

    return this.prisma.order.update({
      where: { id: order.id },
      data: {
        status,
        paymentStatus: status === OrderStatus.DELIVERED ? PaymentStatus.PAID : undefined,
      },
    });
  }

  getDailyReport() {
    return this.buildPeriodReport('day');
  }

  getMonthlyReport() {
    return this.buildPeriodReport('month');
  }

  async updateOrderStatus(id: string, status: OrderStatus) {
    const order = await this.findOrderById(id);
    let assignedDriverId = order.assignedDriverId;

    if (status === OrderStatus.ASSIGNED && !assignedDriverId) {
      const fallbackDriver = await this.prisma.user.findFirst({
        where: { role: 'DRIVER' },
        orderBy: { createdAt: 'asc' },
      });

      if (!fallbackDriver) {
        throw new BadRequestException('No driver is available to assign this order.');
      }

      assignedDriverId = fallbackDriver.id;
    }

    return this.prisma.order.update({
      where: { id: order.id },
      data: {
        status,
        assignedDriverId,
        paymentStatus: status === OrderStatus.DELIVERED ? PaymentStatus.PAID : undefined,
      },
      include: {
        user: { select: { id: true, name: true, email: true, phone: true } },
        assignedDriver: { select: { id: true, name: true, email: true, phone: true } },
        items: { include: { product: true } },
      },
    });
  }

  private async buildPeriodReport(period: 'day' | 'month') {
    const now = new Date();
    const start =
      period === 'day'
        ? new Date(now.getFullYear(), now.getMonth(), now.getDate())
        : new Date(now.getFullYear(), now.getMonth(), 1);

    const deliveredOrders = await this.prisma.order.findMany({
      where: {
        createdAt: { gte: start },
        status: { in: [OrderStatus.DELIVERED, OrderStatus.ON_THE_WAY, OrderStatus.PICKED_UP, OrderStatus.CONFIRMED, OrderStatus.ASSIGNED] },
      },
      include: { items: true },
    });

    const totalRevenue = deliveredOrders.reduce((sum, order) => sum + Number(order.total), 0);
    const totalItemsSold = deliveredOrders.reduce(
      (sum, order) => sum + order.items.reduce((itemSum, item) => itemSum + item.quantity, 0),
      0,
    );

    return {
      period,
      from: start,
      to: now,
      totalOrders: deliveredOrders.length,
      totalItemsSold,
      totalRevenue,
    };
  }

  private async getAssignedDriverOrder(orderId: string, driverId: string) {
    const order = await this.prisma.order.findFirst({
      where: { id: orderId, assignedDriverId: driverId },
    });

    if (!order) {
      throw new NotFoundException('Order not found for this driver.');
    }

    return order;
  }

  private async findOrderById(id: string): Promise<Order> {
    const order = await this.prisma.order.findUnique({ where: { id } });
    if (!order) {
      throw new NotFoundException('Order not found.');
    }

    return order;
  }
}
