import { Modal, Form, Input, message } from 'antd';
import { adminApi } from '../../../api/endpoints/admin';

export default function ResetPasswordModal({ open, account, onClose }) {
  const [form] = Form.useForm();
  const submit = async () => {
    const { newPassword } = await form.validateFields();
    try {
      await adminApi.resetPassword(account.id, newPassword);
      message.success('Đã đặt lại mật khẩu');
      onClose();
    } catch (e) { message.error(e?.response?.data?.error?.message ?? 'Lỗi'); }
  };
  return (
    <Modal title={`Reset mật khẩu — ${account?.username}`} open={open} onOk={submit} onCancel={onClose} destroyOnClose>
      <Form form={form} layout="vertical">
        <Form.Item name="newPassword" label="Mật khẩu mới" rules={[{ required: true, min: 6 }]}>
          <Input.Password/>
        </Form.Item>
      </Form>
    </Modal>
  );
}
