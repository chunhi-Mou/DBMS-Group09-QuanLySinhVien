import { Layout, Avatar, Dropdown, Space } from 'antd';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';
import { LogOut, KeyRound } from 'lucide-react';

export default function AppHeader() {
    const user = useAuthStore((s) => s.user);
    const clear = useAuthStore((s) => s.clear);
    const nav = useNavigate();

    const items = [
        { key: 'pw', icon: <KeyRound size={14} />, label: 'Đổi mật khẩu', onClick: () => nav('/change-password') },
        { type: 'divider' },
        { key: 'out', icon: <LogOut size={14} />, label: 'Đăng xuất', onClick: () => { clear(); nav('/login'); } }
    ];

    return (
        <Layout.Header style={{
            background: '#fff', borderBottom: '2px solid var(--color-primary)',
            display: 'flex', justifyContent: 'flex-end', alignItems: 'center', padding: '0 24px'
        }}>
            <Dropdown menu={{ items }} placement="bottomRight">
                <Space style={{ cursor: 'pointer' }}>
                    <Avatar style={{ background: 'var(--color-primary)' }}>{(user?.hoten || '?').charAt(0)}</Avatar>
                    <span>{user?.hoten || 'Khách'}</span>
                </Space>
            </Dropdown>
        </Layout.Header>
    );
}
