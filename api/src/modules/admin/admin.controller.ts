import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { OrdersService } from '../orders/orders.service';
import { AssignDriverDto } from './dto/assign-driver.dto';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';

@ApiTags('admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
@Controller('admin')
export class AdminController {
  constructor(private readonly ordersService: OrdersService) {}

  @Get('orders')
  getOrders() {
    return this.ordersService.getAllOrders();
  }

  @Get('orders/:id')
  getOrderById(@Param('id') id: string) {
    return this.ordersService.getOrderById(id);
  }

  @Post('orders/:id/assign-driver')
  assignDriver(@Param('id') id: string, @Body() dto: AssignDriverDto) {
    return this.ordersService.assignDriver(id, dto.driverId);
  }

  @Post('orders/:id/status')
  updateOrderStatus(@Param('id') id: string, @Body() dto: UpdateOrderStatusDto) {
    return this.ordersService.updateOrderStatus(id, dto.status);
  }

  @Get('reports/daily')
  getDailyReport() {
    return this.ordersService.getDailyReport();
  }

  @Get('reports/monthly')
  getMonthlyReport() {
    return this.ordersService.getMonthlyReport();
  }
}
