import { Modal, Transfer, message } from 'antd';
import { useEffect, useState } from 'react';
import { adminApi } from '../../../api/endpoints/admin';

export default function AssignMonKyModal({ open, kiHoc, onClose, onSaved }) {
  const [allMon, setAllMon] = useState([]);
  const [target, setTarget] = useState([]);

  useEffect(() => {
    if (!open || !kiHoc) return;
    adminApi.monHocs().then(setAllMon);
    adminApi.monOfKi(kiHoc.id).then(rows => setTarget(rows.map(r => String(r.monHocId))));
  }, [open, kiHoc]);

  const submit = async () => {
    await adminApi.assignMonToKi(kiHoc.id, target.map(Number));
    message.success('Đã lưu môn của kỳ');
    onSaved();
  };

  return (
    <Modal width={800} title={`Gán môn cho kỳ: ${kiHoc?.namHocTen} — ${kiHoc?.hocKiTen}`}
      open={open} onOk={submit} onCancel={onClose} destroyOnClose>
      <Transfer
        dataSource={allMon.map(m => ({ key: String(m.id), title: `${m.ten}` }))}
        targetKeys={target} onChange={setTarget} render={i => i.title} showSearch
        listStyle={{ width: '50%', height: 400 }}
      />
    </Modal>
  );
}
