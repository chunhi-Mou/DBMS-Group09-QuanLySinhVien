import { Layout } from 'antd';
import { Outlet } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';
import RoleSidebar from '../components/RoleSidebar';
import AppHeader from '../components/AppHeader';

export default function MainLayout() {
    const user = useAuthStore((s) => s.user);
    return (
        <Layout style={{ minHeight: '100vh' }}>
            <RoleSidebar role={user?.vaitro} />
            <Layout>
                <AppHeader />
                <Layout.Content className="fade-in" style={{ padding: 24 }}>
                    <Outlet />
                </Layout.Content>
            </Layout>
        </Layout>
    );
}
