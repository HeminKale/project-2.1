/*
  # Fix Application Forms Storage RLS Policies

  1. Problem
    - Bucket name mismatch: policies use 'application_forms' but actual bucket is 'application-forms'
    - RLS policies are preventing authenticated users from uploading files
    - Need to ensure consistent bucket naming and proper permissions

  2. Solution
    - Drop all existing policies for both bucket name variations
    - Create new policies using the correct bucket name 'application-forms'
    - Ensure authenticated users can perform all necessary operations
    - Create the bucket if it doesn't exist

  3. Changes
    - Create application-forms bucket with proper configuration
    - Update all storage policies to use correct bucket name
    - Allow any authenticated user to upload, view, update, and delete files
*/

-- Create the application-forms bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'application-forms',
  'application-forms',
  false,
  52428800, -- 50MB limit
  ARRAY[
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'text/plain',
    'image/jpeg',
    'image/png',
    'image/gif'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  file_size_limit = 52428800,
  allowed_mime_types = ARRAY[
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'text/plain',
    'image/jpeg',
    'image/png',
    'image/gif'
  ];

-- Create the drafts bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'drafts',
  'drafts',
  false,
  52428800, -- 50MB limit
  ARRAY[
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'text/plain',
    'image/jpeg',
    'image/png',
    'image/gif'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  file_size_limit = 52428800,
  allowed_mime_types = ARRAY[
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'text/plain',
    'image/jpeg',
    'image/png',
    'image/gif'
  ];

-- Drop ALL existing storage policies for both bucket name variations
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

-- Create new storage policies for drafts bucket
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

-- Create new storage policies for application-forms bucket (with hyphen)
CREATE POLICY "Authenticated users can upload application forms"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'application-forms' AND
    auth.uid() IS NOT NULL
  );

CREATE POLICY "Authenticated users can view application forms"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'application-forms' AND
    auth.uid() IS NOT NULL
  );

CREATE POLICY "Authenticated users can update application forms"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'application-forms' AND
    auth.uid() IS NOT NULL
  );

CREATE POLICY "Authenticated users can delete application forms"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'application-forms' AND
    auth.uid() IS NOT NULL
  );