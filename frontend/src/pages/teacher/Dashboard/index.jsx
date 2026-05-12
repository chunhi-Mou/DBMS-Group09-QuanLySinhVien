import { useEffect, useState } from 'react';
import { Table, Spin, Alert } from 'antd';
import { teacherApi } from '../../../api/endpoints/teacher';
import ErrorBoundary from '../../../components/ErrorBoundary';

function gpaColor(v) {
  if (v >= 9) return '#52c41a';
  if (v >= 7) return '#1677ff';
  if (v >= 5) return '#fa8c16';
  return '#f5222d';
}

function TeacherDashboard() {
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    teacherApi.dashboard()
      .then(setData)
      .catch(e => setError(e?.response?.data?.error?.message || 'Không thể tải thông tin giảng viên'));
  }, []);

  if (error && !data) return (
    <div className="fade-in">
      <Alert type="error" message={error} showIcon />
    </div>
  );

  if (!data) return <div style={{ textAlign: 'center', padding: 60 }}><Spin /></div>;

  return (
    <div className="fade-in" style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
      {error && <Alert type="error" message={error} showIcon style={{ marginBottom: 2 }} />}

      <div style={{
        background: '#fff',
        border: '1px solid var(--color-border)',
        borderRadius: 6,
        padding: '20px 24px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
      }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
          <div style={{ fontSize: 22, fontWeight: 700, color: '#1f1f1f', fontFamily: 'var(--font-display)' }}>
            {data.hoTen}
          </div>
          <div style={{ fontSize: 13, color: '#888' }}>Mã GV: {data.maGv}</div>
        </div>

        <div style={{ display: 'flex', gap: 40 }}>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: 11, color: '#aaa', marginBottom: 4, fontFamily: 'var(--font-display)' }}>Số lớp kỳ này</div>
            <div style={{ fontSize: 28, fontWeight: 700, color: 'var(--color-primary)', fontFamily: 'var(--font-data)', lineHeight: 1 }}>
              {data.soLopKyHienTai ?? '—'}
            </div>
          </div>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: 11, color: '#aaa', marginBottom: 4, fontFamily: 'var(--font-display)' }}>Tổng SV kỳ này</div>
            <div style={{ fontSize: 28, fontWeight: 700, color: '#333', fontFamily: 'var(--font-data)', lineHeight: 1 }}>
              {data.tongSv ?? '—'}
            </div>
          </div>
        </div>
      </div>

      <div style={{ background: '#fff', border: '1px solid var(--color-border)', borderRadius: 6, overflow: 'hidden' }}>
        <div style={{ padding: '12px 16px', borderBottom: '1px solid var(--color-border)', fontWeight: 600, fontSize: 14, fontFamily: 'var(--font-display)' }}>
          Khối lượng theo kỳ
        </div>
        <Table
          size="middle"
          rowKey="kiHocId"
          pagination={false}
          dataSource={data.theoKi || []}
          locale={{ emptyText: 'Chưa có dữ liệu' }}
          columns={[
            { title: 'Kỳ học', dataIndex: 'kiHocTen' },
            { title: 'Số lớp', dataIndex: 'soLop', width: 100, align: 'center',
              render: v => <span style={{ fontWeight: 600, fontFamily: 'var(--font-data)' }}>{v}</span> },
            { title: 'Tổng SV', dataIndex: 'tongSv', width: 100, align: 'center',
              render: v => <span style={{ fontFamily: 'var(--font-data)' }}>{v}</span> },
          ]}
        />
      </div>
    </div>
  );
}

export default function WrappedTeacherDashboard() {
  return (
    <ErrorBoundary>
      <TeacherDashboard />
    </ErrorBoundary>
  );
}
