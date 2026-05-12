import { Modal, Table, InputNumber, Select, Button, message, Alert, Space } from 'antd';
import { Plus, Trash2 } from 'lucide-react';
import { useEffect, useState } from 'react';
import { adminApi } from '../../../api/endpoints/admin';

export default function ConfigMonModal({ open, monHoc, onClose }) {
  const [items, setItems] = useState([]);
  const [allDD, setAllDD] = useState([]);

  useEffect(() => {
    if (open && monHoc) {
      adminApi.dauDiems().then(setAllDD);
      adminApi.getMonDauDiem(monHoc.id).then(d => setItems(d.items ?? []));
    }
  }, [open, monHoc]);

  const sum = items.reduce((s, x) => s + (Number(x.tile) || 0), 0);
  const addRow = () => setItems([...items, { dauDiemId: null, tile: 0 }]);
  const removeRow = (i) => setItems(items.filter((_, j) => j !== i));
  const update = (i, key, val) => setItems(items.map((x, j) => j === i ? { ...x, [key]: val } : x));

  const submit = async () => {
    if (Math.abs(sum - 1) > 0.001) return message.error(`Tổng tỉ lệ phải = 1.0 (hiện ${sum.toFixed(3)})`);
    if (items.some(x => x.dauDiemId == null)) return message.error('Có dòng chưa chọn đầu điểm');
    try {
      await adminApi.setMonDauDiem(monHoc.id, items.map(x => ({ dauDiemId: x.dauDiemId, tile: Number(x.tile) })));
      message.success('Đã lưu');
      onClose();
    } catch (e) { message.error(e?.response?.data?.error?.message ?? 'Lỗi'); }
  };

  return (
    <Modal width={720} title={`Cấu hình đầu điểm: ${monHoc?.ten}`}
      open={open} onOk={submit} onCancel={onClose} destroyOnClose>
      <Alert
        type={Math.abs(sum-1) < 0.001 ? 'success' : 'warning'}
        showIcon
        message={`Tổng tỉ lệ hiện tại: ${sum.toFixed(3)} (yêu cầu = 1.000)`}
        style={{ marginBottom: 12 }}
      />
      <Table size="small" rowKey={(_, i) => i} dataSource={items} pagination={false}
        columns={[
          { title: 'Đầu điểm', render: (_, r, i) => (
            <Select style={{ width: '100%' }} value={r.dauDiemId} onChange={v => update(i, 'dauDiemId', v)}
              options={allDD.map(dd => ({ value: dd.id, label: dd.ten }))}/>
          )},
          { title: 'Tỉ lệ', width: 140, render: (_, r, i) => (
            <InputNumber min={0} max={1} step={0.05} value={r.tile} onChange={v => update(i, 'tile', v)} style={{ width: '100%' }}/>
          )},
          { title: '', width: 60, render: (_, _r, i) => <Button danger size="small" icon={<Trash2 size={14}/>} onClick={() => removeRow(i)}/> },
        ]}/>
      <Space style={{ marginTop: 12 }}>
        <Button icon={<Plus size={14}/>} onClick={addRow}>Thêm đầu điểm</Button>
      </Space>
    </Modal>
  );
}
