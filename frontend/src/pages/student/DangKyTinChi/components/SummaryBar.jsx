import { Table, Button, Space, message, Modal } from 'antd';
import { useState } from 'react';
import { Check } from 'lucide-react';

export default function SummaryBar({ allChosen, onSubmit, onClearNew, hasNew }) {
  const [submitting, setSubmitting] = useState(false);
  const totalTc = allChosen.reduce((s, l) => s + (l.soTc || 0), 0);

  const submit = async () => {
    setSubmitting(true);
    try {
      const res = await onSubmit();
      if (res.failed?.length) {
        Modal.warning({
          title: 'Một số lớp không thể đăng ký',
          content: <ul>{res.failed.map(f => <li key={f.lhpId}>LHP #{f.lhpId}: {f.lyDo}</li>)}</ul>
        });
      } else {
        message.success(`Đã đăng ký ${res.success.length} lớp`);
      }
    } catch (e) {
      message.error(e.response?.data?.error?.message || 'Lỗi');
    } finally { setSubmitting(false); }
  };

  return (
    <div style={{ borderTop: '2px solid #1677ff', paddingTop: 12, marginTop: 16 }}>
      <Table size="small" rowKey="id" pagination={false} dataSource={allChosen}
        columns={[
          { title: 'Môn', dataIndex: 'monHocTen' },
          { title: 'LHP', dataIndex: 'ten' },
          { title: 'TC', dataIndex: 'soTc', width: 60 },
          { title: 'Trạng thái', render: (_, r) => r.daDangKy ? <span><Check size={12} style={{ marginRight: 3, verticalAlign: -2, color: '#52c41a' }} />Đã ĐK</span> : 'Chờ xác nhận' },
        ]}
      />
      <Space style={{ marginTop: 12, justifyContent: 'space-between', width: '100%' }}>
        <strong>Tổng: {totalTc} TC · {allChosen.length} lớp</strong>
        <Space>
          {hasNew && <Button onClick={onClearNew}>Hủy chọn mới</Button>}
          <Button type="primary" disabled={!hasNew} loading={submitting} onClick={submit}>
            Xác nhận đăng ký
          </Button>
        </Space>
      </Space>
    </div>
  );
}
