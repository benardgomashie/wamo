'use client';

import { Bell, User } from 'lucide-react';

export function Navbar() {
  return (
    <header className="flex h-16 items-center justify-between border-b border-gray-200 bg-white px-8">
      <div className="flex-1">
        {/* Page title will be rendered by individual pages */}
      </div>

      <div className="flex items-center gap-4">
        {/* Notifications */}
        <button className="rounded-lg p-2 text-gray-600 hover:bg-gray-100 transition-colors">
          <Bell className="h-5 w-5" />
        </button>

        {/* User menu */}
        <button className="flex items-center gap-2 rounded-lg p-2 text-gray-700 hover:bg-gray-100 transition-colors">
          <User className="h-5 w-5" />
          <span className="text-sm font-medium">Admin</span>
        </button>
      </div>
    </header>
  );
}
