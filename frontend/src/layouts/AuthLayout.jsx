import { Outlet } from 'react-router-dom';

export default function AuthLayout() {
    return (
        <div style={{
            minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center',
            background: 'linear-gradient(135deg, var(--color-primary-dark), var(--color-primary))'
        }}>
            <Outlet />
        </div>
    );
}
