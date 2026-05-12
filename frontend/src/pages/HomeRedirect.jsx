import { Navigate } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';

export default function HomeRedirect() {
    const role = useAuthStore((s) => s.user?.vaitro);
    if (role === 'SV') return <Navigate to="/student" replace />;
    if (role === 'GV') return <Navigate to="/teacher" replace />;
    if (role === 'ADMIN') return <Navigate to="/admin" replace />;
    return <Navigate to="/login" replace />;
}
