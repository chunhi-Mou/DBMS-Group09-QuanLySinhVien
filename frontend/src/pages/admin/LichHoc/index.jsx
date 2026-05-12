import { useEffect, useState } from 'react';
import { Card, Select, Button, Space, message } from 'antd';
import { Plus } from 'lucide-react';
import { adminApi } from '../../../api/endpoints/admin';
import BuoiHocModal from './BuoiHocModal';
import ScheduleAdminGrid from './ScheduleAdminGrid';

export default function AdminLichHoc() {
  const [kis, setKis] = useState([]);
  const [kiId, setKiId] = useState(null);
  const [rows, setRows] = useState([]);
  const [open, setOpen] = useState(false);

  useEffect(() => { adminApi.kiHocs().then(setKis); }, []);
  useEffect(() => {
    if (!kiId) return;
    adminApi.buoiByKi(kiId).then(setRows);
  }, [kiId]);

  const reload = () => adminApi.buoiByKi(kiId).then(setRows);

  const onDelete = async (id) => {
    await adminApi.deleteBuoi(id);
    message.success('Đã xóa');
    reload();
  };

  return (
    <Card className="fade-in">
      <Space style={{ marginBottom: 12 }}>
        <Select placeholder="Chọn kỳ" value={kiId} onChange={setKiId} style={{ width: 280 }}
          options={kis.map(k => ({ value: k.id, label: `${k.namHocTen} — ${k.hocKiTen}` }))} />
        <Button type="primary" icon={<Plus size={14} />} disabled={!kiId} onClick={() => setOpen(true)}>
          Thêm buổi học
        </Button>
      </Space>
      <ScheduleAdminGrid rows={rows} onDelete={onDelete} />
      {kiId && <BuoiHocModal open={open} kiHocId={kiId} onClose={() => setOpen(false)} onSaved={() => { setOpen(false); reload(); }} />}
    </Card>
  );
}
