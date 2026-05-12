import { useEffect, useState, useMemo } from 'react';
import { Card, Table, Tag, Space, Button, Select, Input, Popconfirm, message, Checkbox } from 'antd';
import { Plus, KeyRound, Trash2, Pencil, Download, Upload } from 'lucide-react';
import { adminApi } from '../../../api/endpoints/admin';
import AccountModal from './AccountModal';
import ResetPasswordModal from './ResetPasswordModal';
import * as XLSX from 'xlsx';

const VAITRO_OPTS = [
  { value: 'SV', label: 'Sinh viên' },
  { value: 'GV', label: 'Giảng viên' },
  { value: 'ADMIN', label: 'Quản lý' },
];
const VAITRO_COLOR = { SV: 'blue', GV: 'orange', ADMIN: 'red' };
const VAITRO_LABEL = { SV: 'Sinh viên', GV: 'Giảng viên', ADMIN: 'Quản lý' };

export default function TaiKhoan() {
  const [rows, setRows] = useState([]);
  const [filterRole, setFilterRole] = useState(null);
  const [searchName, setSearchName] = useState('');
  const [searchEmail, setSearchEmail] = useState('');
  const [editing, setEditing] = useState(null);
  const [openEdit, setOpenEdit] = useState(false);
  const [resetting, setResetting] = useState(null);
  const [selectedKeys, setSelectedKeys] = useState([]);
  const [loading, setLoading] = useState(false);

  const load = async () => {
    setLoading(true);
    const data = await adminApi.listAccounts(filterRole);
    setRows(data);
    setLoading(false);
  };
  useEffect(() => { load(); }, [filterRole]);

  const filtered = useMemo(() => {
    return rows.filter(r => {
      if (searchName && !r.hoTen?.toLowerCase().includes(searchName.toLowerCase())) return false;
      if (searchEmail && !r.email?.toLowerCase().includes(searchEmail.toLowerCase())) return false;
      return true;
    });
  }, [rows, searchName, searchEmail]);

  const handleBulkDelete = async () => {
    let ok = 0, fail = 0;
    for (const id of selectedKeys) {
      try { await adminApi.deleteAccount(id); ok++; }
      catch { fail++; }
    }
    message.info(`Đã xóa ${ok}, lỗi ${fail}`);
    setSelectedKeys([]);
    load();
  };

  const handleExport = () => {
    const exportData = filtered.map(r => ({
      'Username': r.username,
      'Họ tên': r.hoTen,
      'Email': r.email,
      'Vai trò': VAITRO_LABEL[r.vaiTro] ?? r.vaiTro,
      'Mã': r.ma ?? '',
      'Lớp HC': r.lopHanhChinh ?? '',
    }));
    const ws = XLSX.utils.json_to_sheet(exportData);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'TaiKhoan');
    XLSX.writeFile(wb, 'tai_khoan.xlsx');
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
        if (!row['Email'] || !row['Họ tên']) { fail++; continue; }
        try {
          await adminApi.createAccount({
            hoTen: row['Họ tên'],
            email: row['Email'],
            vaiTro: row['Vai trò'] === 'Sinh viên' ? 'SV' : row['Vai trò'] === 'Giảng viên' ? 'GV' : 'ADMIN',
          });
          ok++;
        } catch { fail++; }
      }
      message.info(`Import: ${ok} thành công, ${fail} lỗi`);
      load();
    };
    reader.readAsArrayBuffer(file);
    e.target.value = '';
  };

  const showLopHC = !filterRole || filterRole === 'SV';
  const cols = [
    { title: 'Username', dataIndex: 'username', sorter: (a, b) => (a.username || '').localeCompare(b.username || '') },
    { title: 'Họ tên', dataIndex: 'hoTen', sorter: (a, b) => (a.hoTen || '').localeCompare(b.hoTen || '') },
    { title: 'Email', dataIndex: 'email' },
    { title: 'Mã', dataIndex: 'ma' },
    showLopHC && { title: 'Lớp HC', dataIndex: 'lopHanhChinh' },
    {
      title: 'Vai trò', dataIndex: 'vaiTro',
      render: v => <Tag color={VAITRO_COLOR[v]}>{VAITRO_LABEL[v] ?? v}</Tag>,
    },
    {
      title: '', width: 130, render: (_, r) => (
        <Space size={4}>
          <Button size="small" icon={<Pencil size={14} />} onClick={() => { setEditing(r); setOpenEdit(true); }} />
          <Button size="small" icon={<KeyRound size={14} />} onClick={() => setResetting(r)} />
          <Popconfirm title="Xóa?" onConfirm={async () => { await adminApi.deleteAccount(r.id); message.success('Đã xóa'); load(); }}>
            <Button size="small" danger icon={<Trash2 size={14} />} />
          </Popconfirm>
        </Space>
      ),
    },
  ].filter(Boolean);

  return (
    <div className="fade-in">
      <Card size="small" style={{ marginBottom: 12 }}>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, alignItems: 'center' }}>
          <Select allowClear placeholder="Vai trò" value={filterRole} onChange={v => { setFilterRole(v); setSelectedKeys([]); }}
            options={VAITRO_OPTS} style={{ width: 140 }} />
          <Input placeholder="Tìm tên..." allowClear value={searchName} onChange={e => setSearchName(e.target.value)} style={{ width: 180 }} />
          <Input placeholder="Tìm email..." allowClear value={searchEmail} onChange={e => setSearchEmail(e.target.value)} style={{ width: 200 }} />
          <div style={{ flex: 1 }} />
          <Button icon={<Download size={14} />} onClick={handleExport}>Xuất Excel</Button>
          <Button icon={<Upload size={14} />} onClick={() => document.getElementById('import-file').click()}>Nhập Excel</Button>
          <input id="import-file" type="file" accept=".xlsx,.csv" hidden onChange={handleImport} />
          <Button type="primary" icon={<Plus size={14} />} onClick={() => { setEditing(null); setOpenEdit(true); }}>Thêm</Button>
        </div>
      </Card>

      {selectedKeys.length > 0 && (
        <Card size="small" style={{ marginBottom: 12, background: '#fff1f0', borderColor: '#ffa39e' }}>
          <Space>
            <span>Đã chọn <strong>{selectedKeys.length}</strong> tài khoản</span>
            <Popconfirm title={`Xóa ${selectedKeys.length} tài khoản?`} onConfirm={handleBulkDelete}>
              <Button size="small" danger icon={<Trash2 size={14} />}>Xóa hàng loạt</Button>
            </Popconfirm>
            <Button size="small" onClick={() => setSelectedKeys([])}>Bỏ chọn</Button>
          </Space>
        </Card>
      )}

      <Card size="small">
        <Table rowKey="id" dataSource={filtered} columns={cols} size="small" loading={loading}
          pagination={{ showSizeChanger: true, pageSizeOptions: [10, 25, 50, 100], defaultPageSize: 25, showTotal: (t, r) => `${r[0]}-${r[1]} / ${t}` }}
          rowSelection={{ selectedRowKeys: selectedKeys, onChange: setSelectedKeys }}
          footer={() => <span>{filtered.length} kết quả</span>} />
      </Card>

      <AccountModal open={openEdit} editing={editing} onClose={() => setOpenEdit(false)} onSaved={() => { setOpenEdit(false); load(); }} />
      {resetting && <ResetPasswordModal open={!!resetting} account={resetting} onClose={() => setResetting(null)} />}
    </div>
  );
}
