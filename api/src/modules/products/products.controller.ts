import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  Query,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiConsumes, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { ProductsService } from './products.service';

@ApiTags('products')
@Controller()
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Get('products')
  getProducts(@Query('category') category?: string) {
    return this.productsService.getProducts(category);
  }

  @Get('products/:id')
  getProductById(@Param('id') id: string) {
    return this.productsService.getProductById(id);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Get('admin/products')
  getAdminProducts() {
    return this.productsService.getAdminProducts();
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('file'))
  @Post('admin/products/upload-image')
  uploadProductImage(
    @UploadedFile()
    file: { originalname?: string; mimetype?: string; buffer: Buffer },
  ) {
    const mimeType = this.getImageMimeType(file?.mimetype, file?.originalname);
    const imageUrl = `data:${mimeType};base64,${file.buffer.toString('base64')}`;
    return { imageUrl };
  }

  private getImageMimeType(mimeType?: string, fileName?: string) {
    if (mimeType?.startsWith('image/')) {
      return mimeType;
    }

    const normalizedName = fileName?.toLowerCase() ?? '';
    if (normalizedName.endsWith('.png')) {
      return 'image/png';
    }
    if (normalizedName.endsWith('.webp')) {
      return 'image/webp';
    }
    if (normalizedName.endsWith('.gif')) {
      return 'image/gif';
    }

    return 'image/jpeg';
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Post('admin/products')
  createProduct(@Body() dto: CreateProductDto) {
    return this.productsService.createProduct(dto);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Put('admin/products/:id')
  updateProduct(@Param('id') id: string, @Body() dto: UpdateProductDto) {
    return this.productsService.updateProduct(id, dto);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Delete('admin/products/:id')
  deleteProduct(@Param('id') id: string) {
    return this.productsService.deleteProduct(id);
  }
}
