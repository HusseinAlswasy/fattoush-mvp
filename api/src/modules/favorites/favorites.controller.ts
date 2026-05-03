import { Controller, Delete, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { FavoritesService } from './favorites.service';

@ApiTags('favorites')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.CUSTOMER)
@Controller('favorites')
export class FavoritesController {
  constructor(private readonly favoritesService: FavoritesService) {}

  @Get()
  getFavorites(@CurrentUser() user: AuthenticatedUser) {
    return this.favoritesService.getFavorites(user.sub);
  }

  @Post(':productId')
  addFavorite(@CurrentUser() user: AuthenticatedUser, @Param('productId') productId: string) {
    return this.favoritesService.addFavorite(user.sub, productId);
  }

  @Delete(':productId')
  removeFavorite(@CurrentUser() user: AuthenticatedUser, @Param('productId') productId: string) {
    return this.favoritesService.removeFavorite(user.sub, productId);
  }
}
