import { Form, Input, Button, message } from 'antd';
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { authApi } from '../../../api/endpoints/auth';
import { useAuthStore } from '../../../stores/authStore';
import s from './Login.module.css';

const HOME = { SV: '/student', GV: '/teacher', ADMIN: '/admin' };

export default function Login() {
    const [loading, setLoading] = useState(false);
    const setAuth = useAuthStore((x) => x.setAuth);
    const nav = useNavigate();

    const onFinish = async (values) => {
        setLoading(true);
        try {
            const data = await authApi.login(values);
            setAuth({ token: data.token, user: { vaitro: data.vaitro, hoten: data.hoten, thanhVienId: data.thanhVienId, maSv: data.maSv } });
            nav(HOME[data.vaitro] || '/');
        } catch (e) {
            message.error(e.response?.data?.error?.message || 'Đăng nhập thất bại');
        } finally { setLoading(false); }
    };

    return (
        <div className={s.card}>
            <div className={s.title}>QLSV</div>
            <div className={s.sub}>Hệ thống quản lý sinh viên</div>
            <Form layout="vertical" onFinish={onFinish}>
                <Form.Item name="username" label="Tài khoản" rules={[{ required: true, message: 'Nhập tài khoản' }]}>
                    <Input autoFocus />
                </Form.Item>
                <Form.Item name="password" label="Mật khẩu" rules={[{ required: true, message: 'Nhập mật khẩu' }]}>
                    <Input.Password />
                </Form.Item>
                <Button type="primary" htmlType="submit" loading={loading} block>Đăng nhập</Button>
            </Form>
        </div>
    );
}
