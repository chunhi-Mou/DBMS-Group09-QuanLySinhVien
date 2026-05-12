import { Modal, Form, Select, message } from 'antd';
import { useEffect, useState } from 'react';
import { adminApi } from '../../../api/endpoints/admin';

export default function BuoiHocModal({ open, kiHocId, onClose, onSaved }) {
  const [form] = Form.useForm();
  const [lhps, setLhps] = useState([]);
  const [tuans, setTuans] = useState([]);
  const [ngays, setNgays] = useState([]);
  const [kips, setKips] = useState([]);
  const [phongs, setPhongs] = useState([]);
  const [gvs, setGvs] = useState([]);

  useEffect(() => {
    if (!open) return;
    Promise.all([
      adminApi.adminLhps(kiHocId), adminApi.tuans(), adminApi.ngays(),
      adminApi.kips(), adminApi.phongs(), adminApi.giangViens()
    ]).then(([l, t, n, k, p, g]) => { setLhps(l); setTuans(t); setNgays(n); setKips(k); setPhongs(p); setGvs(g); });
    form.resetFields();
  }, [open, kiHocId, form]);

  const submit = async () => {
    const v = await form.validateFields();
    try {
      await adminApi.createBuoi(v);
      message.success('Đã tạo buổi học');
      onSaved();
    } catch (e) {
      message.error(e?.response?.data?.error?.message ?? 'Lỗi');
    }
  };

  return (
    <Modal title="Thêm buổi học" open={open} onOk={submit} onCancel={onClose} destroyOnClose>
      <Form form={form} layout="vertical">
        <Form.Item name="lhpId" label="Lớp học phần" rules={[{ required: true }]}>
          <Select showSearch optionFilterProp="label" options={lhps.map(l => ({ value: l.id, label: `${l.tenMon} — ${l.ten}` }))} />
        </Form.Item>
        <Form.Item name="tuanId" label="Tuần" rules={[{ required: true }]}>
          <Select options={tuans.map(t => ({ value: t.id, label: t.ten }))} />
        </Form.Item>
        <Form.Item name="ngayId" label="Ngày" rules={[{ required: true }]}>
          <Select options={ngays.map(n => ({ value: n.id, label: n.ten }))} />
        </Form.Item>
        <Form.Item name="kipId" label="Kíp" rules={[{ required: true }]}>
          <Select options={kips.map(k => ({ value: k.id, label: k.ten }))} />
        </Form.Item>
        <Form.Item name="phongHocId" label="Phòng" rules={[{ required: true }]}>
          <Select options={phongs.map(p => ({ value: p.id, label: p.ten }))} />
        </Form.Item>
        <Form.Item name="giangVienId" label="Giảng viên" rules={[{ required: true }]}>
          <Select showSearch optionFilterProp="label" options={gvs.map(g => ({ value: g.id, label: `${g.username} — ${g.hoTen}` }))} />
        </Form.Item>
      </Form>
    </Modal>
  );
}
