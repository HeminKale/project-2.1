/*
  # Fix Storage RLS Policies

  1. Problem
    - Storage bucket policies for 'drafts' and 'application_forms' are too restrictive
    - They check if auth.uid() matches the created_by field of the client record
    - This causes 403 errors when authenticated users try to upload files

  2. Solution
    - Update all storage policies to allow any authenticated user
    - Change from checking created_by relationship to simply checking auth.uid() IS NOT NULL
    - This aligns with the general client management permissions

  3. Changes
    - Update INSERT, SELECT, UPDATE, DELETE policies for both buckets
    - Maintain security by requiring authentication while allowing broader access
*/

-- Drop existing storage policies for drafts bucket
DROP POLICY IF EXISTS "Users can upload their own drafts" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own drafts" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own drafts" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own drafts" ON storage.objects;

-- Drop existing storage policies for application_forms bucket
DROP POLICY IF EXISTS "Users can upload their own application forms" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own application forms" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own application forms" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own application forms" ON storage.objects;

-- Create new storage policies for drafts bucket (allow any authenticated user)
CREATE POLICY "Authenticated users can upload drafts"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'drafts' AND
    auth.uid() IS NOT NULL
  );

CREATE POLICY "Authenticated users can view drafts"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'drafts' AND
    auth.uid() IS NOT NULL
  );

CREATE POLICY "Authenticated users can update drafts"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'drafts' AND
    auth.uid() IS NOT NULL
  );

CREATE POLICY "Authenticated users can delete drafts"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'drafts' AND
    auth.uid() IS NOT NULL
  );

-- Create new storage policies for application_forms bucket (allow any authenticated user)
CREATE POLICY "Authenticated users can upload application forms"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'application_forms' AND
    auth.uid() IS NOT NULL
  );

CREATE POLICY "Authenticated users can view application forms"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'application_forms' AND
    auth.uid() IS NOT NULL
  );

CREATE POLICY "Authenticated users can update application forms"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'application_forms' AND
    auth.uid() IS NOT NULL
  );

CREATE POLICY "Authenticated users can delete application forms"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'application_forms' AND
    auth.uid() IS NOT NULL
  );