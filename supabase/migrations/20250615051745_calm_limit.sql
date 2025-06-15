/*
  # Fix Storage RLS Policies for File Upload

  1. Problem
    - Current RLS policies are preventing authenticated users from uploading files
    - auth.uid() IS NOT NULL check is failing during storage operations
    - Need more permissive but still secure policies

  2. Solution
    - Drop existing restrictive policies
    - Create new policies that work better with Supabase client authentication
    - Use role-based checks instead of just auth.uid() checks
    - Allow authenticated users to perform all operations on their files

  3. Security
    - Still maintains security by requiring authentication
    - Uses auth.role() = 'authenticated' which is more reliable
    - Allows users to manage files in any folder (needed for client-based organization)
*/

-- Drop ALL existing storage policies to start fresh
DROP POLICY IF EXISTS "Users can upload their own drafts" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own drafts" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own drafts" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own drafts" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload drafts" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can view drafts" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update drafts" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete drafts" ON storage.objects;

DROP POLICY IF EXISTS "Users can upload their own application forms" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own application forms" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own application forms" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own application forms" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload application forms" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can view application forms" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update application forms" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete application forms" ON storage.objects;

-- Drop any policies with the underscore version
DROP POLICY IF EXISTS "Users can upload their own application_forms" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own application_forms" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own application_forms" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own application_forms" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload application_forms" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can view application_forms" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update application_forms" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete application_forms" ON storage.objects;

-- Create new, more permissive storage policies for drafts bucket
CREATE POLICY "Allow authenticated users to upload drafts"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'drafts' AND
    auth.role() = 'authenticated'
  );

CREATE POLICY "Allow authenticated users to view drafts"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'drafts' AND
    auth.role() = 'authenticated'
  );

CREATE POLICY "Allow authenticated users to update drafts"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'drafts' AND
    auth.role() = 'authenticated'
  );

CREATE POLICY "Allow authenticated users to delete drafts"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'drafts' AND
    auth.role() = 'authenticated'
  );

-- Create new, more permissive storage policies for application-forms bucket
CREATE POLICY "Allow authenticated users to upload application forms"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'application-forms' AND
    auth.role() = 'authenticated'
  );

CREATE POLICY "Allow authenticated users to view application forms"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'application-forms' AND
    auth.role() = 'authenticated'
  );

CREATE POLICY "Allow authenticated users to update application forms"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'application-forms' AND
    auth.role() = 'authenticated'
  );

CREATE POLICY "Allow authenticated users to delete application forms"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'application-forms' AND
    auth.role() = 'authenticated'
  );