/*
  # Buffalo Predictions Game Schema
  
  Creates the complete database schema for the Spotify prediction game.
  
  ## New Tables
  
  1. **profiles**
     - `id` (uuid, primary key) - References auth.users
     - `email` (text, unique) - User email
     - `display_name` (text) - Display name
     - `is_admin` (boolean) - Admin flag
     - `created_at` (timestamptz) - Account creation timestamp
  
  2. **submissions**
     - `id` (uuid, primary key)
     - `user_id` (uuid) - References profiles
     - `year` (integer) - Competition year
     - `artists` (text[]) - 5 predicted artists in ranked order
     - `songs` (text[]) - 5 predicted songs in ranked order
     - `submitted_at` (timestamptz) - Submission timestamp
     - Unique constraint on (user_id, year)
  
  3. **results**
     - `id` (uuid, primary key)
     - `user_id` (uuid) - References profiles
     - `year` (integer) - Competition year
     - `actual_artists` (text[]) - Actual top 5 artists
     - `actual_songs` (text[]) - Actual top 5 songs
     - `entered_at` (timestamptz) - Entry timestamp
     - Unique constraint on (user_id, year)
  
  4. **scores**
     - `id` (uuid, primary key)
     - `user_id` (uuid) - References profiles
     - `year` (integer) - Competition year
     - `correct_artists` (integer) - Number of correct artist picks
     - `correct_songs` (integer) - Number of correct song picks
     - `total_correct` (integer) - Total correct picks
     - `ranking_accuracy_score` (numeric) - Position difference sum (lower is better)
     - `exact_match_score` (integer) - Exact position match points
     - `final_rank` (integer) - Final placement (1-4)
     - `calculated_at` (timestamptz) - Calculation timestamp
     - Unique constraint on (user_id, year)
  
  5. **buffalo_balances**
     - `id` (uuid, primary key)
     - `year` (integer) - Competition year
     - `caller_id` (uuid) - Person who can call buffalo
     - `recipient_id` (uuid) - Person who must drink
     - `balance` (integer) - Number of buffalos owed
     - Unique constraint on (year, caller_id, recipient_id)
  
  6. **buffalo_calls**
     - `id` (uuid, primary key)
     - `caller_id` (uuid) - Person calling buffalo
     - `recipient_id` (uuid) - Person who must take shot
     - `year` (integer) - Competition year
     - `called_at` (timestamptz) - Call timestamp
     - `photo_url` (text) - URL to shot photo
     - `photo_uploaded_at` (timestamptz) - Photo upload timestamp
  
  7. **invites**
     - `id` (uuid, primary key)
     - `token` (text, unique) - Invite token
     - `creator_id` (uuid) - Person who created invite
     - `created_at` (timestamptz) - Creation timestamp
     - `used_by` (uuid) - User who used invite (nullable)
     - `used_at` (timestamptz) - Usage timestamp (nullable)
  
  ## Security
  
  - Enable RLS on all tables
  - Add policies for authenticated user access
  - Restrict admin operations to admin users
  - Allow public read on buffalo feed
*/

-- Profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE NOT NULL,
  display_name text NOT NULL,
  is_admin boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Submissions table
CREATE TABLE IF NOT EXISTS submissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  year integer NOT NULL,
  artists text[] NOT NULL,
  songs text[] NOT NULL,
  submitted_at timestamptz DEFAULT now(),
  UNIQUE(user_id, year)
);

CREATE INDEX IF NOT EXISTS idx_submissions_year ON submissions(year);

ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all submissions"
  ON submissions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert own submissions"
  ON submissions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own submissions"
  ON submissions FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Results table
CREATE TABLE IF NOT EXISTS results (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  year integer NOT NULL,
  actual_artists text[] NOT NULL,
  actual_songs text[] NOT NULL,
  entered_at timestamptz DEFAULT now(),
  UNIQUE(user_id, year)
);

ALTER TABLE results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all results"
  ON results FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can insert results"
  ON results FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.is_admin = true
    )
  );

CREATE POLICY "Admins can update results"
  ON results FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.is_admin = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.is_admin = true
    )
  );

-- Scores table
CREATE TABLE IF NOT EXISTS scores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  year integer NOT NULL,
  correct_artists integer NOT NULL,
  correct_songs integer NOT NULL,
  total_correct integer NOT NULL,
  ranking_accuracy_score numeric NOT NULL,
  exact_match_score integer NOT NULL,
  final_rank integer NOT NULL,
  calculated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, year)
);

CREATE INDEX IF NOT EXISTS idx_scores_year ON scores(year);

ALTER TABLE scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all scores"
  ON scores FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can insert scores"
  ON scores FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.is_admin = true
    )
  );

CREATE POLICY "Admins can update scores"
  ON scores FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.is_admin = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.is_admin = true
    )
  );

-- Buffalo balances table
CREATE TABLE IF NOT EXISTS buffalo_balances (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  year integer NOT NULL,
  caller_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  recipient_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  balance integer NOT NULL,
  UNIQUE(year, caller_id, recipient_id)
);

ALTER TABLE buffalo_balances ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all buffalo balances"
  ON buffalo_balances FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage buffalo balances"
  ON buffalo_balances FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.is_admin = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.is_admin = true
    )
  );

-- Buffalo calls table
CREATE TABLE IF NOT EXISTS buffalo_calls (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  caller_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  recipient_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  year integer NOT NULL,
  called_at timestamptz DEFAULT now(),
  photo_url text,
  photo_uploaded_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_buffalo_calls_recent ON buffalo_calls(called_at DESC);

ALTER TABLE buffalo_calls ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all buffalo calls"
  ON buffalo_calls FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can create buffalo calls"
  ON buffalo_calls FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = caller_id);

CREATE POLICY "Recipients can update their buffalo calls"
  ON buffalo_calls FOR UPDATE
  TO authenticated
  USING (auth.uid() = recipient_id)
  WITH CHECK (auth.uid() = recipient_id);

-- Invites table
CREATE TABLE IF NOT EXISTS invites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token text UNIQUE NOT NULL,
  creator_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  created_at timestamptz DEFAULT now(),
  used_by uuid REFERENCES profiles(id) ON DELETE SET NULL,
  used_at timestamptz
);

ALTER TABLE invites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all invites"
  ON invites FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can create invites"
  ON invites FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Anyone can update invites when using them"
  ON invites FOR UPDATE
  TO authenticated
  USING (used_by IS NULL)
  WITH CHECK (auth.uid() = used_by);