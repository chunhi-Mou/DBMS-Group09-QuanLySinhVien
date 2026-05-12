import { useEffect, useState, useMemo } from 'react';
import { Card, Tabs, Form, Input, InputNumber, Select, Button, Table, Tag, Space, message, Badge, Tooltip } from 'antd';
import { Settings, Download, Upload, BookOpen, ArrowLeft, ClipboardList } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import CrudTable from '../../../components/CrudTable';
import { adminApi } from '../../../api/endpoints/admin';
import * as XLSX from 'xlsx';

export default function NganhMonHoc() {
  return (
    <Card className="fade-in" style={{ borderRadius: 10, boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}>
      <Tabs items={[
        { key: 'n', label: <span><ClipboardList size={14} style={{ marginRight: 6, verticalAlign: -2 }} />Ngành</span>, children: <NganhTab /> },
        { key: 'm', label: <span><BookOpen size={14} style={{ marginRight: 6, verticalAlign: -2 }} />Môn học</span>, children: <MonHocTab /> },
      ]} />
    </Card>
  );
}

/* ─────────── NGÀNH TAB ─────────── */
function NganhTab() {
  const [rows, setRows] = useState([]);
  const [khoas, setKhoas] = useState([]);
  const [search, setSearch] = useState('');
  const navigate = useNavigate();
  const load = () => adminApi.nganhs().then(setRows);
  useEffect(() => { load(); adminApi.khoas().then(setKhoas); }, []);

  const filtered = useMemo(() => {
    if (!search) return rows;
    const s = search.toLowerCase();
    return rows.filter(r => r.ten?.toLowerCase().includes(s));
  }, [rows, search]);

  return (
    <>
      <div style={{ display: 'flex', gap: 8, marginBottom: 12, alignItems: 'center' }}>
        <Input.Search placeholder="Tìm ngành..." allowClear onChange={e => setSearch(e.target.value)} style={{ width: 300 }} />
      </div>
      <CrudTable
        dataSource={filtered}
        columns={[
          { title: 'Tên', dataIndex: 'ten', sorter: (a, b) => (a.ten || '').localeCompare(b.ten || '') },
          { title: 'Khoa', dataIndex: 'khoaId', render: id => {
            const kh = khoas.find(k => k.id === id);
            return kh ? <Tag color="blue">{kh.ten}</Tag> : id;
          }},
          { title: 'Chương trình đào tạo', render: (_, r) => (
            <Button type="primary" ghost size="small" icon={<Settings size={14} />}
              onClick={() => navigate(`/admin/nganh-monhoc/curriculum/${r.id}`, { state: { nganhTen: r.ten } })}>
              Quản lý CTĐT
            </Button>
          )},
        ]}
        onCreate={async (v) => { await adminApi.createNganh(v); load(); }}
        onUpdate={async (id, v) => { await adminApi.updateNganh(id, v); load(); }}
        onDelete={async (id) => { await adminApi.deleteNganh(id); load(); }}
        renderForm={() => (
          <>
            <Form.Item name="ten" label="Tên ngành" rules={[{ required: true }]}><Input /></Form.Item>
            <Form.Item name="khoaId" label="Khoa" rules={[{ required: true }]}>
              <Select options={khoas.map(k => ({ value: k.id, label: k.ten }))} showSearch optionFilterProp="label" />
            </Form.Item>
          </>
        )}
      />
    </>
  );
}

/* ─────────── MÔN HỌC TAB ─────────── */
function MonHocTab() {
  const [rows, setRows] = useState([]);
  const [boMons, setBoMons] = useState([]);
  const [search, setSearch] = useState('');
  const load = () => adminApi.monHocs().then(setRows);
  useEffect(() => { load(); adminApi.boMons().then(setBoMons); }, []);

  const filtered = useMemo(() => {
    if (!search) return rows;
    const s = search.toLowerCase();
    return rows.filter(r =>
      r.ten?.toLowerCase().includes(s) ||
      r.mamh?.toLowerCase().includes(s) ||
      r.mota?.toLowerCase().includes(s)
    );
  }, [rows, search]);

  const handleExport = () => {
    const data = filtered.map(r => ({
      'Mã MH': r.mamh ?? '',
      'Tên': r.ten,
      'Số TC': r.sotc,
      'Mô tả': r.mota ?? '',
      'Bộ môn': boMons.find(b => b.id === r.boMonId)?.ten ?? '',
    }));
    const ws = XLSX.utils.json_to_sheet(data);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'MonHoc');
    XLSX.writeFile(wb, 'mon_hoc.xlsx');
  };

  const handleImport = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = async (evt) => {
      const wb = XLSX.read(evt.target.result, { type: 'array' });
      const data = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]]);
      let ok = 0, fail = 0;
      for (const row of data) {
        if (!row['Tên'] || !row['Số TC']) { fail++; continue; }
        try {
          await adminApi.createMonHoc({ ten: row['Tên'], sotc: row['Số TC'], mota: row['Mô tả'] ?? '' });
          ok++;
        } catch { fail++; }
      }
      message.info(`Import: ${ok} thành công, ${fail} lỗi`);
      load();
    };
    reader.readAsArrayBuffer(file);
    e.target.value = '';
  };

  return (
    <>
      <div style={{ display: 'flex', gap: 8, marginBottom: 12, flexWrap: 'wrap' }}>
        <Input.Search placeholder="Tìm mã, tên, mô tả..." allowClear onChange={e => setSearch(e.target.value)} style={{ width: 300 }} />
        <div style={{ flex: 1 }} />
        <Button icon={<Download size={14} />} onClick={handleExport}>Xuất Excel</Button>
        <Button icon={<Upload size={14} />} onClick={() => document.getElementById('import-monhoc').click()}>Nhập Excel</Button>
        <input id="import-monhoc" type="file" accept=".xlsx,.csv" hidden onChange={handleImport} />
      </div>
      <CrudTable
        dataSource={filtered}
        columns={[
          { title: 'Mã MH', dataIndex: 'mamh', width: 100, sorter: (a, b) => (a.mamh || '').localeCompare(b.mamh || '') },
          { title: 'Tên', dataIndex: 'ten', sorter: (a, b) => (a.ten || '').localeCompare(b.ten || '') },
          { title: 'TC', dataIndex: 'sotc', width: 60, sorter: (a, b) => (a.sotc || 0) - (b.sotc || 0) },
          { title: 'Mô tả', dataIndex: 'mota', ellipsis: true },
          { title: 'Bộ môn', dataIndex: 'boMonId', render: id => {
            const bm = boMons.find(b => b.id === id);
            return bm ? <Tag>{bm.ten}</Tag> : id;
          }},
        ]}
        onCreate={async (v) => { await adminApi.createMonHoc(v); load(); }}
        onUpdate={async (id, v) => { await adminApi.updateMonHoc(id, v); load(); }}
        onDelete={async (id) => { await adminApi.deleteMonHoc(id); load(); }}
        renderForm={() => (
          <>
            <Form.Item name="ten" label="Tên môn học" rules={[{ required: true }]}><Input /></Form.Item>
            <Form.Item name="mamh" label="Mã MH"><Input /></Form.Item>
            <Form.Item name="sotc" label="Số tín chỉ" rules={[{ required: true }]}><InputNumber min={1} max={10} /></Form.Item>
            <Form.Item name="mota" label="Mô tả"><Input.TextArea rows={2} /></Form.Item>
            <Form.Item name="boMonId" label="Bộ môn" rules={[{ required: true }]}>
              <Select options={boMons.map(b => ({ value: b.id, label: b.ten }))} showSearch optionFilterProp="label" />
            </Form.Item>
          </>
        )}
      />
    </>
  );
}
