import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, MinLength } from 'class-validator';

export class LoginDto {
  @ApiProperty({ required: false, example: 'customer@example.com' })
  @IsOptional()
  @IsString()
  email?: string;

  @ApiProperty({ required: false, example: '+971500000000' })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiProperty({ minLength: 6 })
  @IsString()
  @MinLength(6)
  password: string;
}
