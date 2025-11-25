/*
  # Enhance Buffalo Predictions Schema - New Features
  
  Adds support for enhanced social features, notifications, timers, and media.
  
  ## Schema Changes
  
  1. **Extend buffalo_calls table**
     - Add `timer_deadline` (timestamptz) - Deadline for uploading proof
     - Add `status` (text) - Call status: pending, completed, expired
     - Add `message` (text) - Optional message when calling buffalo
     - Add `video_url` (text) - Support for video proof in addition to photos
     
  2. **Extend profiles table**
     - Add `profile_photo_url` (text) - User profile photo
     - Add `bio` (text) - User bio/tagline
     - Add `spotify_playlist_url` (text) - Link to user's Spotify playlist
     
  3. **Create notifications table**
     - `id` (uuid, primary key)
     - `user_id` (uuid) - Recipient of notification
     - `type` (text) - Notification type
     - `title` (text) - Notification title
     - `message` (text) - Notification body
     - `link` (text) - Optional link to related content
     - `read` (boolean) - Read status
     - `created_at` (timestamptz) - Creation timestamp
     
  4. **Create feed_events table**
     - `id` (uuid, primary key)
     - `event_type` (text) - Type: submission, buffalo_call, result, playlist_share
     - `user_id` (uuid) - Primary user involved
     - `related_user_id` (uuid) - Secondary user (nullable)
     - `year` (integer) - Competition year
     - `title` (text) - Event title
     - `description` (text) - Event description
     - `media_url` (text) - Optional media
     - `metadata` (jsonb) - Additional data
     - `created_at` (timestamptz) - Event timestamp
  
  ## Security
  
  - Enable RLS on new tables
  - Add appropriate policies for authenticated users
*/

-- Extend buffalo_calls table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'buffalo_calls' AND column_name = 'timer_deadline'
  ) THEN
    ALTER TABLE buffalo_calls ADD COLUMN timer_deadline timestamptz;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'buffalo_calls' AND column_name = 'status'
  ) THEN
    ALTER TABLE buffalo_calls ADD COLUMN status text DEFAULT 'pending';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'buffalo_calls' AND column_name = 'message'
  ) THEN
    ALTER TABLE buffalo_calls ADD COLUMN message text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'buffalo_calls' AND column_name = 'video_url'
  ) THEN
    ALTER TABLE buffalo_calls ADD COLUMN video_url text;
  END IF;
END $$;

-- Extend profiles table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'profile_photo_url'
  ) THEN
    ALTER TABLE profiles ADD COLUMN profile_photo_url text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'bio'
  ) THEN
    ALTER TABLE profiles ADD COLUMN bio text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'spotify_playlist_url'
  ) THEN
    ALTER TABLE profiles ADD COLUMN spotify_playlist_url text;
  END IF;
END $$;

-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  type text NOT NULL,
  title text NOT NULL,
  message text NOT NULL,
  link text,
  read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create feed_events table
CREATE TABLE IF NOT EXISTS feed_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type text NOT NULL,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  related_user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  year integer NOT NULL,
  title text NOT NULL,
  description text,
  media_url text,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_feed_events_created_at ON feed_events(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_feed_events_year ON feed_events(year);
CREATE INDEX IF NOT EXISTS idx_feed_events_type ON feed_events(event_type);

ALTER TABLE feed_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all feed events"
  ON feed_events FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can create feed events"
  ON feed_events FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Add constraint for buffalo_calls status
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'buffalo_calls_status_check'
  ) THEN
    ALTER TABLE buffalo_calls
    ADD CONSTRAINT buffalo_calls_status_check
    CHECK (status IN ('pending', 'completed', 'expired'));
  END IF;
END $$;

-- Add constraint for feed_events event_type
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'feed_events_type_check'
  ) THEN
    ALTER TABLE feed_events
    ADD CONSTRAINT feed_events_type_check
    CHECK (event_type IN ('submission', 'buffalo_call', 'result', 'playlist_share', 'ranking'));
  END IF;
END $$;