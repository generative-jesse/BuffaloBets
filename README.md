# Buffalo Predictions

A mobile-optimized web app for competing with friends to predict Spotify Wrapped results. Winners earn "buffalos" - the ability to call someone and make them take a shot on demand.

## Features

- **User Authentication**: Email/password signup and login via Supabase
- **Annual Predictions**: Submit top 5 artists and songs before Spotify Wrapped releases
- **Automatic Scoring**: Complex scoring system with multiple tiebreakers
- **Buffalo System**: Winners earn buffalos on lower-ranked players
- **Social Feed**: Call buffalos and upload shot proof photos
- **Historical Data**: View past years' results and rankings
- **Admin Panel**: Enter actual results and trigger scoring calculations
- **Mobile-First Design**: Optimized for mobile with bottom navigation

## Tech Stack

- **Framework**: Next.js 13 (App Router)
- **Styling**: Tailwind CSS + shadcn/ui components
- **Database**: Supabase (PostgreSQL)
- **Storage**: Supabase Storage (for shot photos)
- **Authentication**: Supabase Auth

## Getting Started

1. Install dependencies:
```bash
npm install
```

2. Set up environment variables in `.env`:
```
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
```

3. The database schema is already applied via the migration.

4. Run the development server:
```bash
npm run dev
```

5. Open [http://localhost:3000](http://localhost:3000)

## Usage Flow

### For Players

1. **Sign Up**: Create an account with email/password
2. **Submit Predictions**: Enter your predicted top 5 artists and songs (ranked)
3. **Wait for Results**: After Spotify Wrapped releases in early December
4. **View Rankings**: See your score and final placement
5. **Use Buffalos**: Call buffalo on players you have buffalos on
6. **Upload Proof**: If someone calls buffalo on you, take the shot and upload photo

### For Admins

1. **Wait for Wrapped**: After Spotify Wrapped releases
2. **Enter Results**: Go to Admin Panel and enter each player's actual top 5
3. **Automatic Calculation**: Scores and buffalo balances are calculated automatically
4. **Rankings Finalized**: All players can now see their results

## Scoring System

### Primary Metric
Total correct picks (artists + songs) - higher is better

### Tiebreaker 1
Ranking accuracy score - sum of position differences for correct picks - lower is better

### Tiebreaker 2
Exact match score - points for exact position matches:
- Position 1 = 5 points
- Position 2 = 4 points
- Position 3 = 3 points
- Position 4 = 2 points
- Position 5 = 1 point

## Buffalo Distribution

Based on final rankings (4 players):
- **1st place** gets buffalos on: 2nd (1), 3rd (2), 4th (3)
- **2nd place** gets buffalos on: 3rd (1), 4th (2)
- **3rd place** gets buffalos on: 4th (1)

## Database Schema

See the migration file for complete schema. Key tables:
- `profiles` - User accounts
- `submissions` - Player predictions
- `results` - Actual Spotify data (admin-entered)
- `scores` - Calculated scores and rankings
- `buffalo_balances` - Who owes who buffalos
- `buffalo_calls` - Feed of buffalo calls and responses
- `invites` - Friend invitation system

## Making Your First Admin

After creating your account, run this SQL in your Supabase SQL editor:

```sql
UPDATE profiles SET is_admin = true WHERE email = 'your-email@example.com';
```

## Project Structure

```
app/
├── auth/          # Authentication pages
├── submit/        # Prediction submission
├── feed/          # Buffalo feed
├── history/       # Historical results
├── profile/       # User profile
└── admin/         # Admin panel

components/
└── bottom-nav.tsx # Mobile navigation

lib/
├── supabase.ts    # Supabase client
├── auth-context.tsx # Auth state management
└── scoring.ts     # Scoring algorithms
```

## License

MIT
