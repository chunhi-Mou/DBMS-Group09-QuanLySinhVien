import { useEffect, useState } from 'react';
import { Card, Form, Input, InputNumber, Select, Button, Table, Tag, Space, Popconfirm, message, Modal } from 'antd';
import { Plus, Settings, Trash2, Pencil } from 'lucide-react';
import { adminApi } from '../../../api/endpoints/admin';
import AssignGvModal from './AssignGvModal';

export default function LopHocPhanPage() {
  const [rows, setRows] = useState([]);
  const [kis, setKis] = useState([]);
  const [filterKi, setFilterKi] = useState(null);
  const [editing, setEditing] = useState(null);
  const [openForm, setOpenForm] = useState(false);
  const [assigning, setAssigning] = useState(null);
  const [form] = Form.useForm();
  const [mks, setMks] = useState([]);

  const load = () => adminApi.adminLhps(filterKi).then(setRows);
  useEffect(() => { load(); }, [filterKi]);
  useEffect(() => { adminApi.kiHocs().then(setKis); }, []);
  useEffect(() => {
    if (filterKi) adminApi.monOfKi(filterKi).then(setMks);
  }, [filterKi]);

  const submit = async () => {
    const v = await form.validateFields();
    try {
      if (editing) await adminApi.updateLhp(editing.id, v);
      else await adminApi.createLhp(v);
      message.success('Đã lưu');
      setOpenForm(false); load();
    } catch (e) { message.error(e?.response?.data?.error?.message ?? 'Lỗi'); }
  };

  const cols = [
    { title: 'Tên LHP', dataIndex: 'ten' },
    { title: 'Môn', render: (_, r) => r.tenMon },
    { title: 'Kỳ', dataIndex: 'kiHocTen' },
    { title: 'Sĩ số', render: (_, r) => `${r.siSoHienTai}/${r.siSoToiDa}` },
    { title: 'GV', render: (_, r) => (r.giangVien ?? []).map(g => <Tag key={g.giangVienId}>{g.username}</Tag>) },
    {
      title: 'Hành động', render: (_, r) => (
        <Space>
          <Button size="small" icon={<Pencil size={14} />} onClick={() => {
            setEditing(r); form.setFieldsValue({ ten: r.ten, monHocKiHocId: r.monHocKiHocId, siSoToiDa: r.siSoToiDa });
            setOpenForm(true);
          }} />
          <Button size="small" icon={<Settings size={14} />} onClick={() => setAssigning(r)}>GV</Button>
          <Popconfirm title="Xóa?" onConfirm={async () => { await adminApi.deleteLhp(r.id); load(); message.success('Đã xóa'); }}>
            <Button size="small" danger icon={<Trash2 size={14} />} />
          </Popconfirm>
        </Space>
      )
    },
  ];

  return (
    <Card className="fade-in">
      <Space style={{ marginBottom: 12 }}>
        <Select allowClear placeholder="Lọc kỳ" value={filterKi} onChange={setFilterKi} style={{ width: 240 }}
          options={kis.map(k => ({ value: k.id, label: `${k.namHocTen} — ${k.hocKiTen}` }))} />
        <Button type="primary" icon={<Plus size={14} />} onClick={() => {
          if (!filterKi) return message.warning('Chọn kỳ trước');
          setEditing(null); form.resetFields();
          setOpenForm(true);
        }}>Thêm LHP</Button>
      </Space>
      <Table rowKey="id" dataSource={rows} columns={cols} size="small" />

      <Modal title={editing ? 'Sửa LHP' : 'Thêm LHP'} open={openForm} onOk={submit} onCancel={() => setOpenForm(false)} destroyOnClose>
        <Form form={form} layout="vertical">
          <Form.Item name="ten" label="Tên LHP" rules={[{ required: true }]}><Input /></Form.Item>
          <Form.Item name="monHocKiHocId" label="Môn (trong kỳ đã chọn)" rules={[{ required: true }]}>
            <Select disabled={!!editing} options={mks.map(m => ({ value: m.id, label: m.tenMon }))} />
          </Form.Item>
          <Form.Item name="siSoToiDa" label="Sĩ số tối đa" rules={[{ required: true }]}><InputNumber min={1} max={500} /></Form.Item>
        </Form>
      </Modal>

      {assigning && <AssignGvModal open={!!assigning} lhp={assigning} onClose={() => setAssigning(null)} onSaved={() => { setAssigning(null); load(); }} />}
    </Card>
  );
}
