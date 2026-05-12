import { useEffect, useState } from 'react';
import { Card, Tabs, Form, Input, Select, Button, Table, Popconfirm, Space, message } from 'antd';
import { Plus, Settings, Trash2 } from 'lucide-react';
import CrudTable from '../../../components/CrudTable';
import { adminApi } from '../../../api/endpoints/admin';
import AssignMonKyModal from './AssignMonKyModal';

export default function KiHocPage() {
  return (
    <Card className="fade-in">
      <Tabs items={[
        { key: 'n', label: 'Năm học', children: <NamHocTab /> },
        { key: 'h', label: 'Học kỳ', children: <HocKiTab /> },
        { key: 'k', label: 'Kỳ học', children: <KiHocTab /> },
      ]} />
    </Card>
  );
}

function NamHocTab() {
  const [rows, setRows] = useState([]);
  const load = () => adminApi.namHocs().then(setRows);
  useEffect(() => { load(); }, []);
  return (
    <CrudTable
      dataSource={rows}
      columns={[{ title: 'Tên', dataIndex: 'ten' }]}
      onCreate={async v => { await adminApi.createNamHoc(v); load(); }}
      onUpdate={async (id, v) => { await adminApi.updateNamHoc(id, v); load(); }}
      onDelete={async id => { await adminApi.deleteNamHoc(id); load(); }}
      renderForm={() => <Form.Item name="ten" label="Tên năm học (vd. 2025-2026)" rules={[{ required: true }]}><Input /></Form.Item>}
    />
  );
}

function HocKiTab() {
  const [rows, setRows] = useState([]);
  const load = () => adminApi.hocKis().then(setRows);
  useEffect(() => { load(); }, []);
  return (
    <CrudTable
      dataSource={rows}
      columns={[{ title: 'Tên', dataIndex: 'ten' }]}
      onCreate={async v => { await adminApi.createHocKi(v); load(); }}
      onUpdate={async (id, v) => { await adminApi.updateHocKi(id, v); load(); }}
      onDelete={async id => { await adminApi.deleteHocKi(id); load(); }}
      renderForm={() => <Form.Item name="ten" label="Tên học kỳ (vd. HK1)" rules={[{ required: true }]}><Input /></Form.Item>}
    />
  );
}

function KiHocTab() {
  const [rows, setRows] = useState([]);
  const [nams, setNams] = useState([]);
  const [hocKis, setHocKis] = useState([]);
  const [namId, setNamId] = useState(null);
  const [hkId, setHkId] = useState(null);
  const [assigning, setAssigning] = useState(null);

  const load = () => adminApi.kiHocs().then(setRows);
  useEffect(() => {
    load();
    adminApi.namHocs().then(setNams);
    adminApi.hocKis().then(setHocKis);
  }, []);

  const create = async () => {
    if (!namId || !hkId) return message.warning('Chọn năm học và học kỳ');
    try { await adminApi.createKiHoc(namId, hkId); message.success('Đã tạo'); load(); }
    catch (e) { message.error(e?.response?.data?.error?.message ?? 'Lỗi'); }
  };

  return (
    <>
      <Space style={{ marginBottom: 12 }}>
        <Select placeholder="Năm học" value={namId} onChange={setNamId} style={{ width: 200 }}
          options={nams.map(n => ({ value: n.id, label: n.ten }))} />
        <Select placeholder="Học kỳ" value={hkId} onChange={setHkId} style={{ width: 160 }}
          options={hocKis.map(h => ({ value: h.id, label: h.ten }))} />
        <Button type="primary" icon={<Plus size={14} />} onClick={create}>Tạo kỳ học</Button>
      </Space>
      <Table size="small" rowKey="id" dataSource={rows} columns={[
        { title: 'Năm học', dataIndex: 'namHocTen' },
        { title: 'Học kỳ', dataIndex: 'hocKiTen' },
        {
          title: 'Hành động', render: (_, r) => (
            <Space>
              <Button size="small" icon={<Settings size={14} />} onClick={() => setAssigning(r)}>Gán môn</Button>
              <Popconfirm title="Xóa?" onConfirm={async () => { await adminApi.deleteKiHoc(r.id); load(); message.success('Đã xóa'); }}>
                <Button size="small" danger icon={<Trash2 size={14} />} />
              </Popconfirm>
            </Space>
          )
        },
      ]} />
      {assigning && <AssignMonKyModal open={!!assigning} kiHoc={assigning} onClose={() => setAssigning(null)} onSaved={() => setAssigning(null)} />}
    </>
  );
}
