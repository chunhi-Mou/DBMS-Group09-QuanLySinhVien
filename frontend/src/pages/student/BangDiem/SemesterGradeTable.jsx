import { Table, Tag } from 'antd';
import { scoreColor } from '../../../utils/scoreColor';

/**
 * SemesterGradeTable Component (Requirements 16, 17, 18)
 * 
 * Displays a flat grade table for a single semester with:
 * - Semester header ribbon with gradient background
 * - Component grade columns (Chuyên cần, Giữa kỳ, Cuối kỳ)
 * - Zebra striping for scannability
 * - Summary block below the table
 */

function SummaryItem({ label, value, color }) {
  return (
    <div>
      <div style={{ 
        fontSize: 14, 
        color: '#888', 
        marginBottom: 4,
        fontFamily: 'var(--font-display)'
      }}>
        {label}
      </div>
      <div style={{ 
        fontSize: 18, 
        fontWeight: 700, 
        color: color,
        fontFamily: 'var(--font-data)',
        lineHeight: 1
      }}>
        {value}
      </div>
    </div>
  );
}

export default function SemesterGradeTable({ semester }) {
  const { courses = [], summary = {} } = semester;

  const columns = [
    {
      title: 'Môn học',
      dataIndex: 'monHoc',
      width: '28%',
      render: (text) => (
        <span style={{ fontWeight: 500 }}>{text}</span>
      )
    },
    {
      title: 'TC',
      dataIndex: 'soTc',
      width: 55,
      align: 'center'
    },
    {
      title: 'Chuyên cần',
      children: [
        {
          title: 'Điểm',
          dataIndex: ['diemThanhPhan', 'chuyenCan', 'diem'],
          width: 70,
          align: 'center',
          render: (v) => v != null ? v.toFixed(1) : <span style={{ color: '#ccc' }}>N/A</span>
        },
        {
          title: 'Tỉ lệ',
          dataIndex: ['diemThanhPhan', 'chuyenCan', 'tile'],
          width: 60,
          align: 'center',
          render: (v) => v ? <span style={{ color: '#888', fontSize: 12 }}>{(v * 100).toFixed(0)}%</span> : <span style={{ color: '#ccc' }}>—</span>
        }
      ]
    },
    {
      title: 'Giữa kỳ',
      children: [
        {
          title: 'Điểm',
          dataIndex: ['diemThanhPhan', 'giuaKy', 'diem'],
          width: 70,
          align: 'center',
          render: (v) => v != null ? v.toFixed(1) : <span style={{ color: '#ccc' }}>N/A</span>
        },
        {
          title: 'Tỉ lệ',
          dataIndex: ['diemThanhPhan', 'giuaKy', 'tile'],
          width: 60,
          align: 'center',
          render: (v) => v ? <span style={{ color: '#888', fontSize: 12 }}>{(v * 100).toFixed(0)}%</span> : <span style={{ color: '#ccc' }}>—</span>
        }
      ]
    },
    {
      title: 'Cuối kỳ',
      children: [
        {
          title: 'Điểm',
          dataIndex: ['diemThanhPhan', 'cuoiKy', 'diem'],
          width: 70,
          align: 'center',
          render: (v) => v != null ? v.toFixed(1) : <span style={{ color: '#ccc' }}>N/A</span>
        },
        {
          title: 'Tỉ lệ',
          dataIndex: ['diemThanhPhan', 'cuoiKy', 'tile'],
          width: 60,
          align: 'center',
          render: (v) => v ? <span style={{ color: '#888', fontSize: 12 }}>{(v * 100).toFixed(0)}%</span> : <span style={{ color: '#ccc' }}>—</span>
        }
      ]
    },
    {
      title: 'Điểm tổng',
      dataIndex: 'diemTong',
      width: 90,
      align: 'center',
      render: (v) => v != null ? (
        <span style={{ 
          fontWeight: 600, 
          color: scoreColor(v),
          fontFamily: 'var(--font-data)' 
        }}>
          {v.toFixed(2)}
        </span>
      ) : <span style={{ color: '#ccc' }}>N/A</span>
    },
    {
      title: 'Hệ chữ',
      dataIndex: 'heChu',
      width: 75,
      align: 'center',
      render: (v) => v ? (
        <Tag color="blue" style={{ fontWeight: 600 }}>{v}</Tag>
      ) : <span style={{ color: '#ccc' }}>—</span>
    },
    {
      title: 'Hệ 4',
      dataIndex: 'diem4',
      width: 65,
      align: 'center',
      render: (v) => v != null ? (
        <span style={{ fontFamily: 'var(--font-data)' }}>
          {v.toFixed(1)}
        </span>
      ) : <span style={{ color: '#ccc' }}>—</span>
    }
  ];

  return (
    <div style={{ borderRadius: 6, overflow: 'hidden', border: '1px solid var(--color-border)' }}>
      {/* Semester header ribbon (Requirement 17) */}
      <div style={{
        background: 'linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%)',
        color: '#fff',
        padding: '12px 20px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
      }}>
        <div>
          <span style={{ fontSize: 16, fontWeight: 600 }}>
            {semester.kiHocTen}
          </span>
          {semester.namHoc && (
            <span style={{ 
              marginLeft: 12, 
              fontSize: 13, 
              opacity: 0.9 
            }}>
              {semester.namHoc} - Học kỳ {semester.hocKy}
            </span>
          )}
        </div>
        <div style={{ fontSize: 13, opacity: 0.9 }}>
          {courses.length} môn học
        </div>
      </div>

      {/* Flat table (Requirement 17: no expand/collapse) */}
      <Table
        dataSource={courses}
        columns={columns}
        pagination={false}
        size="middle"
        rowKey="monHoc"
        bordered
        rowClassName={(record, index) => 
          index % 2 === 0 ? 'grade-row-even' : 'grade-row-odd'
        }
        style={{ borderRadius: 0 }}
      />

      {/* Semester summary block (Requirement 18) */}
      {(summary.gpa10 != null || summary.gpa4 != null) && (
        <div style={{
          background: '#f5f5f5',
          borderTop: '1px solid #e5e5e5',
          padding: '16px 20px',
          display: 'flex',
          gap: 40,
          alignItems: 'center',
          flexWrap: 'wrap',
        }}>
          <SummaryItem 
            label="GPA hệ 10" 
            value={summary.gpa10 != null ? summary.gpa10.toFixed(2) : '—'}
            color={summary.gpa10 != null ? scoreColor(summary.gpa10) : '#ccc'}
          />
          <SummaryItem 
            label="GPA hệ 4" 
            value={summary.gpa4 != null ? summary.gpa4.toFixed(2) : '—'}
            color="#333"
          />
          <SummaryItem 
            label="TC đạt kỳ này" 
            value={summary.creditsEarned ?? '—'}
            color="var(--color-primary)"
          />
          <SummaryItem 
            label="TC tích lũy" 
            value={summary.cumulativeCredits ?? '—'}
            color="var(--color-success)"
          />
        </div>
      )}

      <style>{`
        .grade-row-even td { background: #fff !important; }
        .grade-row-odd td { background: #fafafa !important; }
      `}</style>
    </div>
  );
}
