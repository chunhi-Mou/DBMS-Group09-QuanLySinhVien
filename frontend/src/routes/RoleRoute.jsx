import { Navigate, Outlet } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';

export default function RoleRoute({ allow }) {
    const role = useAuthStore((s) => s.user?.vaitro);
    return allow.includes(role) ? <Outlet /> : <Navigate to="/" replace />;
}
