import { useEffect, useState } from 'react';
import { Table, Tag, Spin, Alert } from 'antd';
import { useNavigate } from 'react-router-dom';
import { ArrowRight } from 'lucide-react';
import AcademicPerformanceChart from './AcademicPerformanceChart';
import EmptyState from '../../../components/EmptyState';
import { studentApi } from '../../../api/endpoints/student';
import { scoreColor } from '../../../utils/scoreColor';
import './Dashboard.css';

const HOC_LUC_COLOR = {
  'Xuất sắc': { bg: '#f6ffed', text: '#237804', border: '#b7eb8f' },
  'Giỏi':     { bg: '#003d4d', text: '#ffffff', border: '#006d75' },
  'Khá':      { bg: '#614700', text: '#ffffff', border: '#874d00' },
  'Trung bình': { bg: '#fff7e6', text: '#873800', border: '#ffd591' },
  'Yếu':      { bg: '#fff1f0', text: '#a8071a', border: '#ffa39e' },
};

function gpa10Color(v) {
  if (v >= 9) return '#52c41a';
  if (v >= 7) return '#1677ff';
  if (v >= 5) return '#fa8c16';
  return '#f5222d';
}

export default function StudentDashboard() {
  const [data, setData] = useState(null);
  const [grades, setGrades] = useState(null);
  const [gradesLoading, setGradesLoading] = useState(false);
  const [error, setError] = useState(null);
  const [gradesError, setGradesError] = useState(null);
  const nav = useNavigate();

  useEffect(() => {
    studentApi.dashboard()
      .then(setData)
      .catch(e => setError(e?.response?.data?.error?.message || 'Không thể tải thông tin sinh viên'));
  }, []);

  // Fetch grades for the most recent semester automatically
  useEffect(() => {
    if (!data || !data.history || data.history.length === 0) return;
    
    // Get the most recent semester (first in the history array)
    const mostRecentSemester = data.history[0];
    if (!mostRecentSemester) return;
    
    setGradesLoading(true);
    setGradesError(null);
    studentApi.grades(mostRecentSemester.kiHocId)
      .then(setGrades)
      .catch(e => setGradesError(e?.response?.data?.error?.message || 'Không thể tải bảng điểm'))
      .finally(() => setGradesLoading(false));
  }, [data]);

  if (error && !data) return (
    <div className="fade-in">
      <Alert type="error" message={error} showIcon />
    </div>
  );

  if (!data) return <div style={{ textAlign: 'center', padding: 60 }}><Spin /></div>;

  return (
    <div className="fade-in dashboard-container">
      {error && <Alert type="error" message={error} showIcon style={{ marginBottom: 2 }} />}

      {/* Student info header */}
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
            {data.hoten}
          </div>
          <div style={{ fontSize: 13, color: '#888' }}>
            Mã SV: {data.maSv} • PTIT
          </div>
          {data.hocLucCurrent && (() => {
            const c = HOC_LUC_COLOR[data.hocLucCurrent] || {};
            return (
              <span style={{
                alignSelf: 'flex-start', marginTop: 4,
                padding: '2px 10px', borderRadius: 4, fontSize: 12, fontWeight: 500,
                background: c.bg || '#f5f5f5', color: c.text || '#555',
                border: `1px solid ${c.border || '#d9d9d9'}`,
              }}>
                {data.hocLucCurrent}
              </span>
            );
          })()}
        </div>

        <div style={{ display: 'flex', gap: 40, justifyContent: 'flex-end' }}>
          <div style={{ textAlign: 'center', minWidth: 80 }}>
            <div style={{ fontSize: 11, color: '#aaa', marginBottom: 8, fontFamily: 'var(--font-display)' }}>GPA hệ 10</div>
            <div style={{ fontSize: 28, fontWeight: 700, color: gpa10Color(data.gpaCurrent), fontFamily: 'var(--font-data)', lineHeight: 1 }}>
              {data.gpaCurrent?.toFixed(2) ?? '—'}
            </div>
          </div>
          <div style={{ textAlign: 'center', minWidth: 80 }}>
            <div style={{ fontSize: 11, color: '#aaa', marginBottom: 8, fontFamily: 'var(--font-display)' }}>GPA hệ 4</div>
            <div style={{ fontSize: 28, fontWeight: 700, color: '#333', fontFamily: 'var(--font-data)', lineHeight: 1 }}>
              {data.gpa4Current?.toFixed(2) ?? '—'}
            </div>
          </div>
          <div style={{ textAlign: 'center', minWidth: 80 }}>
            <div style={{ fontSize: 11, color: '#aaa', marginBottom: 8, fontFamily: 'var(--font-display)' }}>TC tích lũy</div>
            <div style={{ fontSize: 28, fontWeight: 700, color: 'var(--color-primary)', fontFamily: 'var(--font-data)', lineHeight: 1 }}>
              {data.tinChiTichLuy ?? '—'}
            </div>
          </div>
        </div>
      </div>

      {/* Academic Performance Chart */}
      <AcademicPerformanceChart history={data.history} />

      {/* Recent Grades - Most Recent Semester Only */}
      <div style={{ background: '#fff', border: '1px solid var(--color-border)', borderRadius: 6, overflow: 'hidden' }}>
        <div style={{ 
          padding: '12px 16px', 
          borderBottom: '1px solid var(--color-border)', 
          display: 'flex', 
          alignItems: 'center', 
          justifyContent: 'space-between' 
        }}>
          <span style={{ fontWeight: 600, fontSize: 14, fontFamily: 'var(--font-display)' }}>
            Điểm kỳ gần nhất
            {data.history && data.history.length > 0 && (
              <span style={{ fontWeight: 400, color: '#888', marginLeft: 8 }}>
                ({data.history[0].tenKi})
              </span>
            )}
          </span>
          {/* Show "View All Grades" link if student has more than 1 semester */}
          {data.history && data.history.length > 1 && (
            <a 
              onClick={() => nav('/student/bang-diem')}
              style={{ 
                fontSize: 13, 
                color: 'var(--color-primary)', 
                cursor: 'pointer',
                textDecoration: 'none'
              }}
              onMouseEnter={(e) => e.target.style.textDecoration = 'underline'}
              onMouseLeave={(e) => e.target.style.textDecoration = 'none'}
            >
              Xem tất cả điểm <ArrowRight size={13} style={{ marginLeft: 4, verticalAlign: -2 }} />
            </a>
          )}
        </div>
        {gradesError && <Alert type="error" message={gradesError} showIcon style={{ margin: '8px 16px' }} />}
        {gradesLoading ? (
          <div style={{ textAlign: 'center', padding: 32 }}><Spin /></div>
        ) : grades ? (
          <Table
            rowKey="monHoc"
            size="middle"
            dataSource={grades.mon || []}
            pagination={false}
            expandable={{
              expandedRowRender: (row) => (
                <Table
                  size="small"
                  pagination={false}
                  rowKey="ten"
                  dataSource={row.diemThanhPhan || []}
                  columns={[
                    { title: 'Đầu điểm', dataIndex: 'ten' },
                    { title: 'Tỉ lệ', dataIndex: 'tile', render: v => `${((v || 0) * 100).toFixed(0)}%` },
                    { title: 'Điểm', dataIndex: 'diem', render: v => v?.toFixed(2) ?? '—' },
                  ]}
                />
              ),
            }}
            columns={[
              { title: 'Môn học', dataIndex: 'monHoc' },
              { title: 'TC', dataIndex: 'soTc', width: 55, align: 'center' },
              {
                title: 'Điểm tổng', dataIndex: 'diemTong', width: 110, align: 'center',
                render: v => v != null
                  ? <span style={{ fontWeight: 600, color: scoreColor(v), fontFamily: 'var(--font-data)' }}>{v.toFixed(2)}</span>
                  : '—',
              },
              {
                title: 'Hệ chữ', dataIndex: 'heChu', width: 80, align: 'center',
                render: v => v ? <Tag color="blue" style={{ fontWeight: 600 }}>{v}</Tag> : '—',
              },
              {
                title: 'Hệ 4', dataIndex: 'diem4', width: 70, align: 'center',
                render: v => v != null
                  ? <span style={{ fontFamily: 'var(--font-data)' }}>{v.toFixed(1)}</span>
                  : '—',
              },
            ]}
            locale={{ emptyText: 'Không có dữ liệu điểm' }}
          />
        ) : (
          <EmptyState 
            message="No grades available yet"
            description="Grades will appear here after your first semester."
          />
        )}
      </div>
    </div>
  );
}
