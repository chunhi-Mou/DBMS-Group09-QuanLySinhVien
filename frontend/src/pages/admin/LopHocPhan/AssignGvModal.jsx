import { Modal, Transfer, message } from 'antd';
import { useEffect, useState } from 'react';
import { adminApi } from '../../../api/endpoints/admin';

export default function AssignGvModal({ open, lhp, onClose, onSaved }) {
  const [gvs, setGvs] = useState([]);
  const [target, setTarget] = useState([]);

  useEffect(() => {
    if (!open || !lhp) return;
    // adminApi.giangViens() returns [{id, username, hoTen}]
    adminApi.giangViens().then(setGvs);
    setTarget((lhp.giangVien ?? []).map(g => String(g.giangVienId)));
  }, [open, lhp]);

  const submit = async () => {
    await adminApi.assignGv(lhp.id, target.map(Number));
    message.success('Đã gán GV');
    onSaved();
  };

  return (
    <Modal width={760} title={`Gán GV — ${lhp?.tenMon} (${lhp?.ten})`}
      open={open} onOk={submit} onCancel={onClose} destroyOnClose>
      <Transfer
        dataSource={gvs.map(g => ({ key: String(g.id), title: `${g.username} — ${g.hoTen}` }))}
        targetKeys={target} onChange={setTarget} render={i => i.title} showSearch
        listStyle={{ width: '50%', height: 360 }}
      />
    </Modal>
  );
}
