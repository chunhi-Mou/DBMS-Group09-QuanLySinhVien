import { Modal, Form, Input, Select, message } from 'antd';
import { useEffect, useState } from 'react';
import { adminApi } from '../../../api/endpoints/admin';

export default function AccountModal({ open, editing, onClose, onSaved }) {
  const [form] = Form.useForm();
  const [nganhs, setNganhs] = useState([]);
  const [lhcs, setLhcs] = useState([]);

  useEffect(() => {
    if (open) {
      if (!editing) {
        adminApi.nganhs().then(setNganhs);
        adminApi.lopHanhChinhs().then(setLhcs);
      }
      form.resetFields();
      if (editing) form.setFieldsValue(editing);
    }
  }, [open, editing, form]);

  const submit = async () => {
    const v = await form.validateFields();
    try {
      if (editing) await adminApi.updateAccount(editing.id, v);
      else await adminApi.createAccount(v);
      message.success('Đã lưu');
      onSaved();
    } catch (e) { message.error(e?.response?.data?.error?.message ?? 'Lỗi'); }
  };

  return (
    <Modal title={editing ? 'Sửa tài khoản' : 'Thêm tài khoản'} open={open} onOk={submit} onCancel={onClose} destroyOnClose>
      <Form form={form} layout="vertical">
        <Form.Item name="username" label="Username" rules={[{ required: true }]}><Input disabled={!!editing}/></Form.Item>
        {!editing && <Form.Item name="password" label="Mật khẩu" rules={[{ required: true, min: 6 }]}><Input.Password/></Form.Item>}
        <Form.Item name="hodem" label="Họ đệm"><Input/></Form.Item>
        <Form.Item name="ten" label="Tên" rules={[{ required: true }]}><Input/></Form.Item>
        <Form.Item name="email" label="Email"><Input/></Form.Item>
        <Form.Item name="sdt" label="SĐT"><Input/></Form.Item>
        <Form.Item name="vaiTro" label="Vai trò" rules={[{ required: true }]}>
          <Select disabled={!!editing} options={[
            { value: 'SV', label: 'Sinh viên' },
            { value: 'GV', label: 'Giảng viên' },
            { value: 'ADMIN', label: 'Quản lý' },
          ]}/>
        </Form.Item>
        <Form.Item shouldUpdate noStyle>
          {() => form.getFieldValue('vaiTro') === 'SV' && !editing && (
            <>
              <Form.Item name="ma" label="Mã SV" rules={[{ required: true }]}><Input/></Form.Item>
              <Form.Item name="nganhId" label="Ngành">
                <Select options={nganhs.map(n => ({ value: n.id, label: n.ten }))}/>
              </Form.Item>
              <Form.Item name="lopHanhChinhId" label="Lớp hành chính">
                <Select allowClear options={lhcs.map(l => ({ value: l.id, label: l.tenLop }))}/>
              </Form.Item>
            </>
          )}
        </Form.Item>
      </Form>
    </Modal>
  );
}
