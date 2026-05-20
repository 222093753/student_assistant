-- ============================================================
-- TPG316C GROUP ASSIGNMENT – SUPABASE DATABASE SETUP
-- Run this ENTIRE script in: Supabase Dashboard → SQL Editor
-- ============================================================

-- ── 1. CREATE TABLE ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sa_applications (
  id                  UUID    DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id             UUID    REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  student_name        VARCHAR(255) NOT NULL,
  student_number      VARCHAR(50)  NOT NULL,
  year_of_study       INTEGER NOT NULL CHECK (year_of_study BETWEEN 1 AND 3),
  module1_level       VARCHAR(50)  NOT NULL,
  module1_name        VARCHAR(255) NOT NULL,
  module2_level       VARCHAR(50),
  module2_name        VARCHAR(255),
  meets_requirements  BOOLEAN NOT NULL DEFAULT FALSE,
  document_url        TEXT,
  status              VARCHAR(20) NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending','approved','rejected')),
  admin_comment       TEXT,
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ── 2. ENABLE ROW LEVEL SECURITY ─────────────────────────────
ALTER TABLE sa_applications ENABLE ROW LEVEL SECURITY;

-- ── 3. STUDENT POLICIES ───────────────────────────────────────
-- Students can only see their OWN applications
CREATE POLICY "Students view own"
  ON sa_applications FOR SELECT
  USING (auth.uid() = user_id);

-- Students can only insert for themselves
CREATE POLICY "Students insert own"
  ON sa_applications FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Students can only update their OWN PENDING applications
CREATE POLICY "Students update own pending"
  ON sa_applications FOR UPDATE
  USING (auth.uid() = user_id AND status = 'pending');

-- Students can only delete their OWN PENDING applications
CREATE POLICY "Students delete own pending"
  ON sa_applications FOR DELETE
  USING (auth.uid() = user_id AND status = 'pending');

-- ── 4. ADMIN POLICIES ────────────────────────────────────────
-- Admin users (role = 'admin' in user_metadata) can manage ALL records

CREATE POLICY "Admins view all"
  ON sa_applications FOR SELECT
  USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');

CREATE POLICY "Admins update all"
  ON sa_applications FOR UPDATE
  USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');

CREATE POLICY "Admins delete all"
  ON sa_applications FOR DELETE
  USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin');

-- ── 5. AUTO-UPDATE updated_at TRIGGER ────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sa_applications_updated_at
  BEFORE UPDATE ON sa_applications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- STORAGE SETUP
-- First: Supabase Dashboard → Storage → New Bucket
--   Name: sa_documents   |   Public: ON
-- Then run these policies:
-- ============================================================

CREATE POLICY "Auth users upload"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'sa_documents');

CREATE POLICY "Public view docs"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'sa_documents');

CREATE POLICY "Auth users delete own"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'sa_documents');

-- ============================================================
-- HOW TO MAKE A USER AN ADMIN:
-- 1. Register an account through the app (Sign Up tab)
-- 2. Go to Supabase Dashboard → Authentication → Users
-- 3. Click on the user → Edit → User Metadata
-- 4. Paste exactly:  { "role": "admin" }
-- 5. Save — that user will now see the Admin Dashboard
-- ============================================================
