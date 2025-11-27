/*
  # Buffalo Request System

  Creates the infrastructure for users to request buffalos on each other with approval workflow.

  ## New Tables

  1. **buffalo_requests**
     - `id` (uuid, primary key)
     - `requester_id` (uuid) - User requesting the buffalo
     - `recipient_id` (uuid) - User who needs to approve
     - `year` (integer) - Competition year
     - `note` (text, nullable) - Optional message from requester
     - `status` (text) - Status: 'pending', 'accepted', 'declined'
     - `created_at` (timestamptz) - Request creation time
     - `responded_at` (timestamptz, nullable) - When recipient responded

  ## Security

  - Enable RLS on buffalo_requests table
  - Users can create requests
  - Users can view requests where they're involved (requester or recipient)
  - Only recipients can update their own requests (accept/decline)

  ## Indexes

  - Index on recipient_id for fast lookup of pending requests
  - Index on status for filtering pending requests
*/

-- Create buffalo_requests table
CREATE TABLE IF NOT EXISTS buffalo_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  recipient_id uuid REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  year integer NOT NULL,
  note text,
  status text DEFAULT 'pending' NOT NULL,
  created_at timestamptz DEFAULT now(),
  responded_at timestamptz,
  CHECK (status IN ('pending', 'accepted', 'declined')),
  CHECK (requester_id != recipient_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_buffalo_requests_recipient ON buffalo_requests(recipient_id) WHERE status = 'pending';
CREATE INDEX IF NOT EXISTS idx_buffalo_requests_requester ON buffalo_requests(requester_id);
CREATE INDEX IF NOT EXISTS idx_buffalo_requests_status ON buffalo_requests(status);

-- Enable RLS
ALTER TABLE buffalo_requests ENABLE ROW LEVEL SECURITY;

-- Users can view requests where they're involved
CREATE POLICY "Users can view their buffalo requests"
  ON buffalo_requests FOR SELECT
  TO authenticated
  USING (
    auth.uid() = requester_id OR auth.uid() = recipient_id
  );

-- Users can create buffalo requests
CREATE POLICY "Users can create buffalo requests"
  ON buffalo_requests FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = requester_id
  );

-- Recipients can update their requests (accept/decline)
CREATE POLICY "Recipients can respond to buffalo requests"
  ON buffalo_requests FOR UPDATE
  TO authenticated
  USING (auth.uid() = recipient_id)
  WITH CHECK (auth.uid() = recipient_id);
