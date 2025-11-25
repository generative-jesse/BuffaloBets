-- Example seed data for Buffalo Predictions
-- Run this after creating your first user account to make them an admin

-- Make the first user an admin (replace with your actual user email)
-- UPDATE profiles SET is_admin = true WHERE email = 'your-email@example.com';

-- Example: Create some test data for 2023
-- Note: You'll need real user IDs from your profiles table

-- Example submissions (replace user_ids with actual values)
-- INSERT INTO submissions (user_id, year, artists, songs) VALUES
-- ('user-id-1', 2023,
--   ARRAY['Taylor Swift', 'Drake', 'The Weeknd', 'Bad Bunny', 'Ed Sheeran'],
--   ARRAY['Anti-Hero', 'Rich Flex', 'Die For You', 'Tití Me Preguntó', 'Shivers']),
-- ('user-id-2', 2023,
--   ARRAY['Drake', 'Taylor Swift', 'Bad Bunny', 'The Weeknd', 'SZA'],
--   ARRAY['Rich Flex', 'Anti-Hero', 'Die For You', 'Kill Bill', 'Flowers']);

-- Example results (entered by admin after Spotify Wrapped)
-- INSERT INTO results (user_id, year, actual_artists, actual_songs) VALUES
-- ('user-id-1', 2023,
--   ARRAY['Taylor Swift', 'The Weeknd', 'Drake', 'Ed Sheeran', 'SZA'],
--   ARRAY['Anti-Hero', 'Die For You', 'Flowers', 'Rich Flex', 'Kill Bill']);

-- Scores and buffalo balances are calculated automatically by the admin panel
