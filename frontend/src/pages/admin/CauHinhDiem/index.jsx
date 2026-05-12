import { useEffect, useState } from 'react';
import { Card, Tabs, Form, Input, InputNumber, Button } from 'antd';
import { Settings } from 'lucide-react';
import CrudTable from '../../../components/CrudTable';
import { adminApi } from '../../../api/endpoints/admin';
import ConfigMonModal from './ConfigMonModal';

export default function CauHinhDiem() {
  return (
    <Card className="fade-in">
      <Tabs items={[
        { key: 'd', label: 'Đầu điểm', children: <DauDiemTab/> },
        { key: 'm', label: 'Cấu hình môn', children: <MonConfigTab/> },
        { key: 'h', label: 'Hệ chữ', children: <HeChuTab/> },
        { key: 'l', label: 'Loại học lực', children: <HocLucTab/> },
      ]}/>
    </Card>
  );
}

function DauDiemTab() {
  const [rows, setRows] = useState([]);
  const load = () => adminApi.dauDiems().then(setRows);
  useEffect(() => { load(); }, []);
  return (
    <CrudTable
      dataSource={rows}
      columns={[{ title: 'Tên', dataIndex: 'ten' }, { title: 'Mô tả', dataIndex: 'mota' }]}
      onCreate={async v => { await adminApi.createDauDiem(v); load(); }}
      onUpdate={async (id,v) => { await adminApi.updateDauDiem(id, v); load(); }}
      onDelete={async id => { await adminApi.deleteDauDiem(id); load(); }}
      renderForm={() => (
        <>
          <Form.Item name="ten" label="Tên đầu điểm" rules={[{ required: true }]}><Input/></Form.Item>
          <Form.Item name="mota" label="Mô tả"><Input/></Form.Item>
        </>
      )}
    />
  );
}

function MonConfigTab() {
  const [rows, setRows] = useState([]);
  const [editing, setEditing] = useState(null);
  useEffect(() => { adminApi.monHocs().then(setRows); }, []);
  return (
    <>
      <p style={{ color: 'var(--color-text-muted)' }}>Chọn môn để cấu hình tỉ lệ các đầu điểm. Tổng tỉ lệ phải bằng 1.0.</p>
      <CrudTable
        dataSource={rows}
        columns={[
          { title: 'Tên', dataIndex: 'ten' },
          { title: 'TC', dataIndex: 'sotc', width: 60 },
          { title: 'Cấu hình', render: (_, r) => <Button size="small" icon={<Settings size={14}/>} onClick={() => setEditing(r)}>Đầu điểm</Button> },
        ]}
        onCreate={() => Promise.reject(new Error('Không khả dụng ở tab này'))}
        onUpdate={() => Promise.reject(new Error('Không khả dụng ở tab này'))}
        onDelete={() => Promise.reject(new Error('Không khả dụng ở tab này'))}
        renderForm={() => null}
      />
      {editing && <ConfigMonModal open={!!editing} monHoc={editing} onClose={() => setEditing(null)}/>}
    </>
  );
}

function HeChuTab() {
  const [rows, setRows] = useState([]);
  const load = () => adminApi.heChu().then(setRows);
  useEffect(() => { load(); }, []);
  return (
    <CrudTable
      dataSource={rows}
      columns={[
        { title: 'Tên (hệ chữ)', dataIndex: 'ten' },
        { title: 'Min (10)', dataIndex: 'diem10Min' },
        { title: 'Max (10)', dataIndex: 'diem10Max' },
        { title: 'Hệ 4', dataIndex: 'diem4' },
      ]}
      onCreate={async v => { await adminApi.createHeChu(v); load(); }}
      onUpdate={async (id,v) => { await adminApi.updateHeChu(id, v); load(); }}
      onDelete={async id => { await adminApi.deleteHeChu(id); load(); }}
      renderForm={() => (
        <>
          <Form.Item name="ten" label="Tên (vd. A+, B, C)" rules={[{ required: true }]}><Input/></Form.Item>
          <Form.Item name="diem10Min" label="Min (thang 10)" rules={[{ required: true }]}><InputNumber min={0} max={10} step={0.5}/></Form.Item>
          <Form.Item name="diem10Max" label="Max (thang 10)" rules={[{ required: true }]}><InputNumber min={0} max={10} step={0.5}/></Form.Item>
          <Form.Item name="diem4" label="Điểm hệ 4" rules={[{ required: true }]}><InputNumber min={0} max={4} step={0.1}/></Form.Item>
        </>
      )}
    />
  );
}

function HocLucTab() {
  const [rows, setRows] = useState([]);
  const load = () => adminApi.hocLuc().then(setRows);
  useEffect(() => { load(); }, []);
  return (
    <CrudTable
      dataSource={rows}
      columns={[
        { title: 'Tên', dataIndex: 'ten' },
        { title: 'GPA min', dataIndex: 'diemMin' },
        { title: 'GPA max', dataIndex: 'diemMax' },
      ]}
      onCreate={async v => { await adminApi.createHocLuc(v); load(); }}
      onUpdate={async (id,v) => { await adminApi.updateHocLuc(id, v); load(); }}
      onDelete={async id => { await adminApi.deleteHocLuc(id); load(); }}
      renderForm={() => (
        <>
          <Form.Item name="ten" label="Tên (vd. Xuất sắc, Giỏi)" rules={[{ required: true }]}><Input/></Form.Item>
          <Form.Item name="diemMin" label="GPA min" rules={[{ required: true }]}><InputNumber min={0} max={4} step={0.1}/></Form.Item>
          <Form.Item name="diemMax" label="GPA max" rules={[{ required: true }]}><InputNumber min={0} max={4} step={0.1}/></Form.Item>
        </>
      )}
    />
  );
}
