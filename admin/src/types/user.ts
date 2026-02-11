export interface User {
  id: string;
  name: string;
  email?: string;
  phone?: string;
  role: 'creator' | 'donor' | 'admin';
  createdAt: Date | string;
}

export interface AdminUser extends User {
  role: 'admin';
}
