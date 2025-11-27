'use client';

import { Beer } from 'lucide-react';
import { useEffect, useState } from 'react';

const loadingMessages = [
  'Loading your predictions...',
  'Fetching buffalo balances...',
  'Loading activity feed...',
  'Getting player stats...',
  'Almost there...',
];

export function LoadingScreen() {
  const [messageIndex, setMessageIndex] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setMessageIndex((prev) => (prev + 1) % loadingMessages.length);
    }, 1500);

    return () => clearInterval(interval);
  }, []);

  return (
    <div className="min-h-screen flex items-center justify-center bg-zinc-950">
      <div className="text-center">
        <div className="relative w-24 h-24 mx-auto mb-6">
          <div className="absolute inset-0 bg-amber-500/20 rounded-full animate-ping" />
          <div className="absolute inset-0 bg-amber-500/40 rounded-full animate-pulse" />
          <div className="relative flex items-center justify-center w-full h-full">
            <Beer className="w-12 h-12 text-amber-500 animate-bounce" />
          </div>
        </div>
        <div className="space-y-2">
          <div className="h-2 w-48 bg-zinc-800 rounded-full overflow-hidden mx-auto">
            <div className="h-full bg-gradient-to-r from-amber-600 to-amber-400 animate-loading-bar" />
          </div>
          <p className="text-zinc-400 animate-fade-in-out">
            {loadingMessages[messageIndex]}
          </p>
        </div>
      </div>
    </div>
  );
}
