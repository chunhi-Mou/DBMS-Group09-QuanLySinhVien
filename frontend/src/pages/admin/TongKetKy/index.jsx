import { useEffect, useState } from 'react';
import { Card, Select, Button, Space, Modal, Table, Tag, message } from 'antd';
import { Check } from 'lucide-react';
import { adminApi } from '../../../api/endpoints/admin';

export default function TongKetKy() {
  const [kis, setKis] = useState([]);
  const [kiId, setKiId] = useState(null);
  const [running, setRunning] = useState(false);
  const [result, setResult] = useState(null);

  useEffect(() => { adminApi.kiHocs().then(setKis); }, []);

  const run = () => {
    Modal.confirm({
      title: 'Chạy tổng kết kỳ?',
      content: 'Tính GPA + học lực cho mọi SV trong kỳ. Có thể chạy lại nhiều lần.',
      okText: 'Chạy',
      onOk: async () => {
        setRunning(true);
        try {
          const r = await adminApi.finalizeSemester(kiId);
          setResult(r);
          message.success(`Hoàn tất: ${r.done.length} SV, ${r.skipped.length} bỏ qua`);
        } finally { setRunning(false); }
      }
    });
  };

  return (
    <Card className="fade-in">
      <Space style={{ marginBottom: 16 }}>
        <Select placeholder="Chọn kỳ" value={kiId} onChange={setKiId} style={{ width: 280 }}
          options={kis.map(k => ({ value: k.id, label: `${k.namHocTen} — ${k.hocKiTen}` }))} />
        <Button type="primary" icon={<Check size={14} />} disabled={!kiId} loading={running} onClick={run}>
          Chạy tổng kết kỳ
        </Button>
      </Space>
      {result && (
        <>
          <Card type="inner" title={`Done (${result.done.length})`} style={{ marginBottom: 12 }}>
            <Table size="small" rowKey="maSv" dataSource={result.done} pagination={{ pageSize: 50 }}
              columns={[
                { title: 'Mã SV', dataIndex: 'maSv' },
                { title: 'GPA 10', dataIndex: 'gpa10' },
                { title: 'GPA 4', dataIndex: 'gpa4' },
                { title: 'TC đạt', render: (_, r) => `${r.tcDat}/${r.tongTc}` },
                { title: 'Học lực', dataIndex: 'hocLuc', render: v => v ? <Tag color="red">{v}</Tag> : '–' },
              ]} />
          </Card>
          {result.skipped.length > 0 && (
            <Card type="inner" title={`Skipped (${result.skipped.length})`}>
              <Table size="small" rowKey="maSv" dataSource={result.skipped}
                columns={[{ title: 'Mã SV', dataIndex: 'maSv' }, { title: 'Lý do', dataIndex: 'lyDo' }]} />
            </Card>
          )}
        </>
      )}
    </Card>
  );
}
