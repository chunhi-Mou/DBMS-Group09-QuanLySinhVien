import { Card, Tag, Button, Badge, Tooltip } from 'antd';
import { useNavigate } from 'react-router-dom';
import { Users, BookOpen, ClipboardList, AlertTriangle } from 'lucide-react';

const CARD_STYLE = {
  borderRadius: 10,
  overflow: 'hidden',
  boxShadow: '0 2px 8px rgba(0,0,0,0.06)',
  transition: 'box-shadow 0.25s ease, transform 0.25s ease',
  height: '100%',
};

export default function ClassCard({ data }) {
  const nav = useNavigate();
  const isEmpty = !data.siSo || data.siSo === 0;
  const fillPct = data.siSoToiDa ? Math.round((data.siSo / data.siSoToiDa) * 100) : 0;
  const fillColor = fillPct >= 90 ? '#f5222d' : fillPct >= 60 ? '#fa8c16' : '#52c41a';

  return (
    <Card
      hoverable
      style={{
        ...CARD_STYLE,
        borderTop: `3px solid ${isEmpty ? '#d9d9d9' : '#1677ff'}`,
        opacity: isEmpty ? 0.6 : 1,
      }}
      styles={{ body: { padding: '16px 18px', display: 'flex', flexDirection: 'column', gap: 10 } }}
    >
      {/* Subject name */}
      <div style={{ fontSize: 15, fontWeight: 700, color: '#1f1f1f', lineHeight: 1.3 }}>
        <BookOpen size={14} style={{ marginRight: 6, verticalAlign: -2, color: '#1677ff' }} />
        {data.monHoc}
      </div>

      {/* Class code */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <Tag color="blue" style={{ margin: 0, fontWeight: 600 }}>{data.ten}</Tag>
        <span style={{ fontSize: 12, color: '#888' }}>{data.kiHocTen}</span>
      </div>

      {/* Student count — visual bar */}
      <div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 4 }}>
          <span style={{ fontSize: 12, fontWeight: 600, color: '#555' }}>
            <Users size={12} style={{ marginRight: 4, verticalAlign: -1 }} />
            Sĩ số
          </span>
          <span style={{ fontSize: 13, fontWeight: 700, color: isEmpty ? '#ccc' : '#333' }}>
            {data.siSo ?? 0} / {data.siSoToiDa ?? '—'}
          </span>
        </div>
        <div style={{ height: 6, borderRadius: 3, background: '#f0f0f0', overflow: 'hidden' }}>
          <div style={{
            width: `${fillPct}%`, height: '100%', borderRadius: 3,
            background: fillColor,
            transition: 'width 0.5s ease',
          }} />
        </div>
      </div>

      {/* Warning if empty */}
      {isEmpty && (
        <div style={{ fontSize: 11, color: '#fa8c16', fontWeight: 500 }}>
          <AlertTriangle size={12} style={{ marginRight: 4, verticalAlign: -1 }} /> Lớp chưa có sinh viên đăng ký
        </div>
      )}

      {/* Action */}
      <Button
        type="primary"
        block
        disabled={isEmpty}
        icon={<ClipboardList size={14} />}
        onClick={() => nav(`/teacher/grades/${data.lhpId}`)}
        style={{ marginTop: 'auto', fontWeight: 600 }}
      >
        Nhập điểm
      </Button>
    </Card>
  );
}
