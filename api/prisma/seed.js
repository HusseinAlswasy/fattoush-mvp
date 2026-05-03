require('dotenv').config();

const {
  PrismaClient,
  UserRole,
  PaymentMethod,
  OrderStatus,
  PaymentStatus,
  PaymentProvider,
} = require('@prisma/client');
const bcrypt = require('bcrypt');

const prisma = new PrismaClient();

async function main() {
  const demoPassword = process.env.SEED_DEMO_PASSWORD;
  if (!demoPassword) {
    throw new Error('SEED_DEMO_PASSWORD is required before running the seed.');
  }

  const passwordHash = await bcrypt.hash(demoPassword, 10);

  const admin = await prisma.user.upsert({
    where: { email: 'admin@fattoush.app' },
    update: {},
    create: {
      name: 'Fattoush Admin',
      email: 'admin@fattoush.app',
      passwordHash,
      role: UserRole.ADMIN,
    },
  });

  const driver = await prisma.user.upsert({
    where: { email: 'driver@fattoush.app' },
    update: {},
    create: {
      name: 'Fattoush Driver',
      email: 'driver@fattoush.app',
      phone: '+971500000001',
      passwordHash,
      role: UserRole.DRIVER,
    },
  });

  const customer = await prisma.user.upsert({
    where: { email: 'customer@fattoush.app' },
    update: {},
    create: {
      name: 'Fattoush Customer',
      email: 'customer@fattoush.app',
      phone: '+971500000002',
      passwordHash,
      role: UserRole.CUSTOMER,
    },
  });

  const existingProducts = await prisma.product.count();
  if (existingProducts === 0) {
    const oliveOil = await prisma.product.create({
      data: {
        name: 'Olive Oil',
        category: 'البقالة',
        description: 'Cold pressed extra virgin olive oil.',
        price: 32.5,
        imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5',
      },
    });

    const pitaBread = await prisma.product.create({
      data: {
        name: 'Pita Bread',
        category: 'المخبوزات',
        description: 'Fresh baked pita bread pack.',
        price: 6,
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff',
      },
    });

    await prisma.product.createMany({
      data: [
        {
          name: 'Egyptian Rice',
          category: 'البقالة',
          description: 'Premium Egyptian rice 1kg.',
          price: 12.5,
          imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c',
        },
        {
          name: 'Grilled Chicken',
          category: 'فراخ',
          description: 'Fresh grilled chicken meal.',
          price: 38,
          imageUrl: 'https://images.unsplash.com/photo-1604503468506-a8da13d82791',
        },
        {
          name: 'Koshari Box',
          category: 'كشري',
          description: 'Traditional Egyptian koshari.',
          price: 18,
          imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19',
        },
        {
          name: 'Mini Pizza',
          category: 'بيتزا',
          description: 'Cheese mini pizza ready to heat.',
          price: 22,
          imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591',
        },
        {
          name: 'Basbousa',
          category: 'حلويات',
          description: 'Fresh basbousa tray slices.',
          price: 15,
          imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587',
        },
      ],
    });

    await prisma.adsBanner.createMany({
      data: [
        {
          title: 'Fresh arrivals',
          imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e',
          productId: oliveOil.id,
        },
        {
          title: 'Bakery specials',
          imageUrl: 'https://images.unsplash.com/photo-1517433670267-08bbd4be890f',
          productId: pitaBread.id,
        },
      ],
    });

    const order = await prisma.order.create({
      data: {
        userId: customer.id,
        status: OrderStatus.ASSIGNED,
        paymentMethod: PaymentMethod.COD,
        paymentStatus: PaymentStatus.UNPAID,
        subtotal: 38.5,
        deliveryFee: 10,
        total: 48.5,
        addressText: 'Dubai Marina, Building 1',
        lat: 25.080389,
        lng: 55.140388,
        assignedDriverId: driver.id,
        items: {
          create: [
            {
              productId: oliveOil.id,
              unitPrice: 32.5,
              quantity: 1,
              lineTotal: 32.5,
            },
            {
              productId: pitaBread.id,
              unitPrice: 6,
              quantity: 1,
              lineTotal: 6,
            },
          ],
        },
        payments: {
          create: {
            provider: PaymentProvider.CASH,
            amount: 48.5,
            currency: 'AED',
            status: PaymentStatus.UNPAID,
          },
        },
      },
    });

    await prisma.driverLocation.upsert({
      where: { driverId: driver.id },
      update: { lat: 25.081221, lng: 55.142114 },
      create: {
        driverId: driver.id,
        lat: 25.081221,
        lng: 55.142114,
      },
    });

    console.log('Seed completed', { orderId: order.id });
  }

  await prisma.product.updateMany({
    where: { name: 'Olive Oil' },
    data: { category: 'البقالة' },
  });

  await prisma.product.updateMany({
    where: { name: 'Pita Bread' },
    data: { category: 'المخبوزات' },
  });

  console.log({
    admin: 'admin@fattoush.app',
    driver: 'driver@fattoush.app',
    customer: 'customer@fattoush.app',
    passwordConfigured: true,
  });
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
