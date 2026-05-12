import { Form, Button, Card, message } from 'antd';
import { useState } from 'react';
import { authApi } from '../../api/endpoints/auth';
import PasswordInput from './PasswordInput';

/**
 * ChangePassword Page (Requirements 19, 20, 21)
 * 
 * - Centered layout with max-width 400px (Req 19)
 * - Full-width Save button with loading state (Req 20)
 * - Password visibility toggle via PasswordInput (Req 21)
 */
export default function ChangePassword() {
    const [loading, setLoading] = useState(false);
    const [form] = Form.useForm();

    const onFinish = async (v) => {
        setLoading(true);
        try {
            await authApi.changePassword(v);
            message.success('Đổi mật khẩu thành công');
            form.resetFields();
        } catch (e) {
            message.error(e.response?.data?.error?.message || 'Lỗi');
        } finally { setLoading(false); }
    };

    return (
        <div style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            minHeight: 'calc(100vh - 64px)',
            padding: 24
        }}>
            <Card 
                title={<span style={{ fontSize: 18, fontWeight: 600 }}>Đổi mật khẩu</span>}
                style={{ 
                    width: '100%',
                    maxWidth: 400,
                    boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
                    borderRadius: 8
                }}
                styles={{ body: { padding: 24 } }}
            >
                <Form form={form} layout="vertical" onFinish={onFinish}>
                    <Form.Item 
                        name="oldPassword" 
                        label="Mật khẩu cũ"
                        rules={[{ required: true, message: 'Vui lòng nhập mật khẩu cũ' }]}
                        style={{ marginBottom: 16 }}
                    >
                        <PasswordInput placeholder="Nhập mật khẩu cũ" />
                    </Form.Item>
                    <Form.Item 
                        name="newPassword" 
                        label="Mật khẩu mới"
                        rules={[
                            { required: true, message: 'Vui lòng nhập mật khẩu mới' },
                            { min: 6, message: 'Mật khẩu phải có ít nhất 6 ký tự' }
                        ]}
                        style={{ marginBottom: 16 }}
                    >
                        <PasswordInput placeholder="Nhập mật khẩu mới" />
                    </Form.Item>
                    <Form.Item 
                        name="confirm" 
                        label="Xác nhận mật khẩu"
                        dependencies={['newPassword']}
                        rules={[
                            { required: true, message: 'Vui lòng xác nhận mật khẩu' },
                            ({ getFieldValue }) => ({
                                validator(_, val) {
                                    return !val || getFieldValue('newPassword') === val
                                        ? Promise.resolve()
                                        : Promise.reject(new Error('Mật khẩu xác nhận không khớp'));
                                }
                            })
                        ]}
                        style={{ marginBottom: 16 }}
                    >
                        <PasswordInput placeholder="Nhập lại mật khẩu mới" />
                    </Form.Item>
                    <Button 
                        type="primary" 
                        htmlType="submit" 
                        loading={loading}
                        block
                        size="large"
                        style={{
                            height: 42,
                            marginTop: 8,
                            background: 'var(--color-primary)',
                            borderColor: 'var(--color-primary)',
                            fontWeight: 500,
                            fontSize: 15
                        }}
                    >
                        {loading ? 'Đang lưu...' : 'Lưu thay đổi'}
                    </Button>
                </Form>
            </Card>
        </div>
    );
}
