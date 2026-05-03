import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { DriverStatusUpdateDto } from './dto/driver-status-update.dto';
import { DriverService } from './driver.service';

@ApiTags('driver')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.DRIVER)
@Controller('driver')
export class DriverController {
  constructor(private readonly driverService: DriverService) {}

  @Get('orders')
  getDriverOrders(@CurrentUser() user: AuthenticatedUser) {
    return this.driverService.getDriverOrders(user.sub);
  }

  @Post('orders/:id/accept')
  acceptDriverOrder(@CurrentUser() user: AuthenticatedUser, @Param('id') id: string) {
    return this.driverService.acceptDriverOrder(id, user.sub);
  }

  @Post('orders/:id/status')
  updateDriverOrderStatus(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: DriverStatusUpdateDto,
  ) {
    return this.driverService.updateDriverOrderStatus(id, user.sub, dto);
  }
}
