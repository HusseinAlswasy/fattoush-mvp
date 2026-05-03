import { ApiProperty } from '@nestjs/swagger';
import type { UserRole } from '@prisma/client';

class UserProfileDto {
  @ApiProperty()
  id: string;

  @ApiProperty({ enum: ['CUSTOMER', 'ADMIN', 'DRIVER'] })
  role: UserRole;

  @ApiProperty({ nullable: true })
  name: string | null;

  @ApiProperty({ nullable: true })
  email: string | null;

  @ApiProperty({ nullable: true })
  phone: string | null;
}

export class AuthResponseDto {
  @ApiProperty()
  accessToken: string;

  @ApiProperty({ type: UserProfileDto })
  user: UserProfileDto;
}
