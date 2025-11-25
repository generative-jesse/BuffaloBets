'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Home, FileText, Newspaper, TrendingUp, User } from 'lucide-react';
import { cn } from '@/lib/utils';

export function BottomNav() {
  const pathname = usePathname();

  const navItems = [
    { href: '/', icon: Home, label: 'Home' },
    { href: '/submit', icon: FileText, label: 'Submit' },
    { href: '/buffalo-board', icon: TrendingUp, label: 'Buffalo' },
    { href: '/feed', icon: Newspaper, label: 'Feed' },
    { href: '/profile', icon: User, label: 'Profile' },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-zinc-900/95 backdrop-blur-lg border-t border-zinc-800 pb-safe z-50">
      <div className="flex justify-around items-center h-16">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = pathname === item.href || (item.href !== '/' && pathname.startsWith(item.href));

          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                'flex flex-col items-center justify-center flex-1 h-full transition-all duration-200 relative button-press',
                isActive
                  ? 'text-amber-500'
                  : 'text-zinc-400 hover:text-zinc-300'
              )}
            >
              {isActive && (
                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-12 h-1 bg-amber-500 rounded-b-full animate-scale-in" />
              )}
              <Icon className={cn(
                'w-5 h-5 mb-1 transition-transform',
                isActive && 'scale-110'
              )} />
              <span className="text-xs font-medium">{item.label}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
