'use client';

import React, { useState, useEffect } from 'react';
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs';
import { Upload, FileText, Download, Trash2, AlertCircle, CheckCircle, Loader2 } from 'lucide-react';

interface ApplicationFormManagerProps {
  clientId: string;
}

interface UploadedFile {
  name: string;
  path: string;
  size: number;
  uploadedAt: string;
  url?: string;
}

export default function ApplicationFormManager({ clientId }: ApplicationFormManagerProps) {
  const [files, setFiles] = useState<UploadedFile[]>([]);
  const [uploading, setUploading] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const supabase = createClientComponentClient();

  // Load existing files on component mount
  useEffect(() => {
    loadFiles();
  }, [clientId]);

  const loadFiles = async () => {
    try {
      setLoading(true);
      setError(null);

      // List files in the client's folder
      const { data: fileList, error: listError } = await supabase.storage
        .from('application-forms')
        .list(clientId, {
          limit: 100,
          offset: 0,
        });

      if (listError) {
        console.error('Error listing files:', listError);
        setError(`Failed to load files: ${listError.message}`);
        return;
      }

      if (fileList) {
        const filesWithUrls = await Promise.all(
          fileList.map(async (file) => {
            const filePath = `${clientId}/${file.name}`;
            
            // Get signed URL for download
            const { data: urlData } = await supabase.storage
              .from('application-forms')
              .createSignedUrl(filePath, 3600); // 1 hour expiry

            return {
              name: file.name,
              path: filePath,
              size: file.metadata?.size || 0,
              uploadedAt: file.created_at || new Date().toISOString(),
              url: urlData?.signedUrl,
            };
          })
        );

        setFiles(filesWithUrls);
      }
    } catch (err) {
      console.error('Error in loadFiles:', err);
      setError('Failed to load application forms');
    } finally {
      setLoading(false);
    }
  };

  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    try {
      setUploading(true);
      setError(null);
      setSuccess(null);

      // Validate file type
      const allowedTypes = [
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

      if (!allowedTypes.includes(file.type)) {
        setError('File type not supported. Please upload PDF, Word, Excel, text, or image files.');
        return;
      }

      // Validate file size (50MB limit)
      if (file.size > 50 * 1024 * 1024) {
        setError('File size must be less than 50MB');
        return;
      }

      // Create unique filename with timestamp
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const fileExtension = file.name.split('.').pop();
      const fileName = `${file.name.split('.')[0]}_${timestamp}.${fileExtension}`;
      const filePath = `${clientId}/${fileName}`;

      console.log('Uploading file:', {
        fileName,
        filePath,
        fileType: file.type,
        fileSize: file.size
      });

      // Upload file to Supabase Storage
      const { data: uploadData, error: uploadError } = await supabase.storage
        .from('application-forms')
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: false
        });

      if (uploadError) {
        console.error('Upload error:', uploadError);
        setError(`Upload failed: ${uploadError.message}`);
        return;
      }

      console.log('Upload successful:', uploadData);
      setSuccess(`File "${file.name}" uploaded successfully!`);

      // Reload files to show the new upload
      await loadFiles();

      // Clear the file input
      event.target.value = '';

    } catch (err) {
      console.error('Error in handleFileUpload:', err);
      setError('An unexpected error occurred during upload');
    } finally {
      setUploading(false);
    }
  };

  const handleFileDelete = async (filePath: string, fileName: string) => {
    if (!confirm(`Are you sure you want to delete "${fileName}"?`)) {
      return;
    }

    try {
      setError(null);
      setSuccess(null);

      const { error: deleteError } = await supabase.storage
        .from('application-forms')
        .remove([filePath]);

      if (deleteError) {
        console.error('Delete error:', deleteError);
        setError(`Failed to delete file: ${deleteError.message}`);
        return;
      }

      setSuccess(`File "${fileName}" deleted successfully!`);
      await loadFiles();
    } catch (err) {
      console.error('Error in handleFileDelete:', err);
      setError('Failed to delete file');
    }
  };

  const handleFileDownload = async (url: string, fileName: string) => {
    try {
      if (!url) {
        setError('Download URL not available');
        return;
      }

      // Create a temporary link and trigger download
      const link = document.createElement('a');
      link.href = url;
      link.download = fileName;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    } catch (err) {
      console.error('Error in handleFileDownload:', err);
      setError('Failed to download file');
    }
  };

  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  const formatDate = (dateString: string): string => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  return (
    <div className="space-y-6">
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Application Forms</h3>
        
        {/* Upload Section */}
        <div className="mb-6">
          <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-gray-400 transition-colors">
            <Upload className="mx-auto h-12 w-12 text-gray-400 mb-4" />
            <div className="space-y-2">
              <p className="text-sm text-gray-600">
                Upload application forms, documents, or supporting files
              </p>
              <p className="text-xs text-gray-500">
                Supported: PDF, Word, Excel, Text, Images (Max 50MB)
              </p>
            </div>
            <label className="mt-4 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed">
              {uploading ? (
                <>
                  <Loader2 className="animate-spin -ml-1 mr-2 h-4 w-4" />
                  Uploading...
                </>
              ) : (
                <>
                  <Upload className="-ml-1 mr-2 h-4 w-4" />
                  Choose File
                </>
              )}
              <input
                type="file"
                className="sr-only"
                onChange={handleFileUpload}
                disabled={uploading}
                accept=".pdf,.doc,.docx,.xls,.xlsx,.txt,.jpg,.jpeg,.png,.gif"
              />
            </label>
          </div>
        </div>

        {/* Status Messages */}
        {error && (
          <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-md flex items-start">
            <AlertCircle className="h-5 w-5 text-red-400 mt-0.5 mr-3 flex-shrink-0" />
            <div>
              <h4 className="text-sm font-medium text-red-800">Upload Error</h4>
              <p className="text-sm text-red-700 mt-1">{error}</p>
            </div>
          </div>
        )}

        {success && (
          <div className="mb-4 p-4 bg-green-50 border border-green-200 rounded-md flex items-start">
            <CheckCircle className="h-5 w-5 text-green-400 mt-0.5 mr-3 flex-shrink-0" />
            <div>
              <h4 className="text-sm font-medium text-green-800">Success</h4>
              <p className="text-sm text-green-700 mt-1">{success}</p>
            </div>
          </div>
        )}

        {/* Files List */}
        <div>
          <h4 className="text-sm font-medium text-gray-900 mb-3">Uploaded Files</h4>
          
          {loading ? (
            <div className="flex items-center justify-center py-8">
              <Loader2 className="animate-spin h-6 w-6 text-gray-400" />
              <span className="ml-2 text-sm text-gray-500">Loading files...</span>
            </div>
          ) : files.length === 0 ? (
            <div className="text-center py-8">
              <FileText className="mx-auto h-12 w-12 text-gray-400 mb-4" />
              <p className="text-sm text-gray-500">No files uploaded yet</p>
            </div>
          ) : (
            <div className="space-y-3">
              {files.map((file, index) => (
                <div
                  key={index}
                  className="flex items-center justify-between p-3 bg-gray-50 rounded-lg border border-gray-200"
                >
                  <div className="flex items-center space-x-3">
                    <FileText className="h-5 w-5 text-gray-400" />
                    <div>
                      <p className="text-sm font-medium text-gray-900">{file.name}</p>
                      <p className="text-xs text-gray-500">
                        {formatFileSize(file.size)} • {formatDate(file.uploadedAt)}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-2">
                    {file.url && (
                      <button
                        onClick={() => handleFileDownload(file.url!, file.name)}
                        className="p-2 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-md transition-colors"
                        title="Download file"
                      >
                        <Download className="h-4 w-4" />
                      </button>
                    )}
                    <button
                      onClick={() => handleFileDelete(file.path, file.name)}
                      className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors"
                      title="Delete file"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}