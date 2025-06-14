'use client';

import Layout from '../components/Layout';
import ChannelPartnerList from '../components/ChannelPartnerList';
import { useAuth } from '../components/AuthProvider';
import LoginForm from '../components/LoginForm';

export default function ChannelPartnersPage() {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!user) {
    return <LoginForm />;
  }

  return (
    <Layout>
      <ChannelPartnerList />
    </Layout>
  );
}