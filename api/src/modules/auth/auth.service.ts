import {
  BadRequestException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Prisma, UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { ChangePasswordDto } from './dto/change-password.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const normalizedEmail = this.normalizeEmail(dto.email);
    const normalizedPhone = this.normalizePhone(dto.phone);
    const normalizedPassword = dto.password.trim();

    if (!normalizedEmail && !normalizedPhone) {
      throw new BadRequestException('Email or phone is required.');
    }

    if (normalizedPassword.length < 6) {
      throw new BadRequestException('Password must be at least 6 characters.');
    }

    const existingUser = await this.prisma.user.findFirst({
      where: {
        OR: this.buildIdentifierWhere({
          email: normalizedEmail,
          phone: normalizedPhone,
        }),
      },
    });

    if (existingUser) {
      throw new BadRequestException('User already exists.');
    }

    const passwordHash = await bcrypt.hash(normalizedPassword, 10);
    const user = await this.prisma.user.create({
      data: {
        name: dto.name,
        email: normalizedEmail,
        phone: normalizedPhone,
        passwordHash,
        role: dto.role ?? UserRole.CUSTOMER,
      },
    });

    return this.buildAuthResponse(user);
  }

  async login(dto: LoginDto) {
    const normalizedEmail = this.normalizeEmail(dto.email);
    const normalizedPhone = this.normalizePhone(dto.phone);
    const normalizedPassword = dto.password.trim();

    if (!normalizedEmail && !normalizedPhone) {
      throw new BadRequestException('Email or phone is required.');
    }

    if (normalizedPassword.length < 6) {
      throw new BadRequestException('Password must be at least 6 characters.');
    }

    const user = await this.prisma.user.findFirst({
      where: {
        OR: this.buildIdentifierWhere({
          email: normalizedEmail,
          phone: normalizedPhone,
        }),
      },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials.');
    }

    const passwordMatches = await bcrypt.compare(
      normalizedPassword,
      user.passwordHash,
    );
    if (!passwordMatches) {
      throw new UnauthorizedException('Invalid credentials.');
    }

    return this.buildAuthResponse(user);
  }

  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found.');
    }

    return {
      id: user.id,
      role: user.role,
      name: user.name,
      email: user.email,
      phone: user.phone,
      createdAt: user.createdAt,
    };
  }

  async changePassword(userId: string, dto: ChangePasswordDto) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found.');
    }

    const currentPassword = dto.currentPassword.trim();
    const newPassword = dto.newPassword.trim();

    const passwordMatches = await bcrypt.compare(
      currentPassword,
      user.passwordHash,
    );

    if (!passwordMatches) {
      throw new UnauthorizedException('Current password is incorrect.');
    }

    if (currentPassword === newPassword) {
      throw new BadRequestException(
        'New password must be different from the current password.',
      );
    }

    if (newPassword.length < 6) {
      throw new BadRequestException('Password must be at least 6 characters.');
    }

    const passwordHash = await bcrypt.hash(newPassword, 10);

    await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash },
    });

    return {
      success: true,
      message: 'Password changed successfully.',
    };
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found.');
    }

    const updatedUser = await this.prisma.user.update({
      where: { id: userId },
      data: {
        name: dto.name?.trim() || user.name,
      },
    });

    return {
      id: updatedUser.id,
      role: updatedUser.role,
      name: updatedUser.name,
      email: updatedUser.email,
      phone: updatedUser.phone,
      createdAt: updatedUser.createdAt,
    };
  }

  private buildAuthResponse(user: {
    id: string;
    role: UserRole;
    name: string | null;
    email: string | null;
    phone: string | null;
  }) {
    const accessToken = this.jwtService.sign({
      sub: user.id,
      role: user.role,
      email: user.email,
      phone: user.phone,
    });

    return {
      accessToken,
      user: {
        id: user.id,
        role: user.role,
        name: user.name,
        email: user.email,
        phone: user.phone,
      },
    };
  }

  private normalizeEmail(email?: string | null): string | null {
    if (!email) {
      return null;
    }

    const trimmed = email.trim().toLowerCase();
    return trimmed.length > 0 ? trimmed : null;
  }

  private normalizePhone(phone?: string | null): string | null {
    if (!phone) {
      return null;
    }

    const trimmed = phone.replace(/\s+/g, '').replace(/-/g, '');
    return trimmed.length > 0 ? trimmed : null;
  }

  private buildIdentifierWhere(params: {
    email: string | null;
    phone: string | null;
  }) {
    const orConditions: Prisma.UserWhereInput[] = [];

    if (params.email) {
      orConditions.push({ email: params.email });
    }

    if (params.phone) {
      orConditions.push({ phone: params.phone });

      const withoutPlus = params.phone.startsWith('+')
        ? params.phone.slice(1)
        : `+${params.phone}`;
      orConditions.push({ phone: withoutPlus });
    }

    if (orConditions.length === 0) {
      orConditions.push({
        id: '__never_match__',
      });
    }

    return orConditions;
  }
}
