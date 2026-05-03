import type { UserRole } from '@prisma/client';

export type AuthenticatedUser = {
  sub: string;
  role: UserRole;
  email: string | null;
  phone: string | null;
};
