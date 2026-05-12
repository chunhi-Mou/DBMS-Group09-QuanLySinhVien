import { Tooltip } from 'antd';

const NGAY = [1, 2, 3, 4, 5, 6];
const NGAY_LABELS = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
const KIPS = [1, 2, 3, 4, 5, 6];
const KIP_META = {
  1: { label: 'Kíp 1', time: '07:00–08:50' },
  2: { label: 'Kíp 2', time: '09:00–10:50' },
  3: { label: 'Kíp 3', time: '12:00–13:50' },
  4: { label: 'Kíp 4', time: '14:00–15:50' },
  5: { label: 'Kíp 5', time: '16:00–17:50' },
  6: { label: 'Kíp 6', time: '18:00–19:50' },
};

/**
 * Color assignment (Requirement 12): 
 * Single primary color for standard classes,
 * distinct colors only for special types.
 * Maximum 4 colors total.
 */
const SCHEDULE_COLORS = {
  standard: {
    bg: 'var(--schedule-standard-bg, #e6f4ff)',
    text: 'var(--schedule-standard-text, #1a1a1a)',
    border: 'var(--schedule-standard-border, #91caff)',
  },
  exam: {
    bg: 'var(--schedule-exam-bg, #fff1f0)',
    text: 'var(--schedule-exam-text, #1a1a1a)',
    border: 'var(--schedule-exam-border, #ffa39e)',
  },
  makeup: {
    bg: 'var(--schedule-makeup-bg, #fff7e6)',
    text: 'var(--schedule-makeup-text, #1a1a1a)',
    border: 'var(--schedule-makeup-border, #ffd591)',
  },
  lab: {
    bg: 'var(--schedule-lab-bg, #f6ffed)',
    text: 'var(--schedule-lab-text, #1a1a1a)',
    border: 'var(--schedule-lab-border, #b7eb8f)',
  },
};

function getClassColor(classItem) {
  if (classItem.loai === 'THI') return SCHEDULE_COLORS.exam;
  if (classItem.loai === 'BU') return SCHEDULE_COLORS.makeup;
  if (classItem.loai === 'TH') return SCHEDULE_COLORS.lab;
  return SCHEDULE_COLORS.standard;
}

const thStyle = {
  padding: '8px 6px',
  borderBottom: '2px solid var(--color-primary)',
  borderRight: '1px solid #e0e0e0',
  textAlign: 'center',
  fontWeight: 600,
  background: '#fff5f5',
  whiteSpace: 'nowrap',
  fontSize: 13,
  color: '#333',
};

const timeCellStyle = {
  padding: '0 8px',
  borderBottom: '1px solid #ebebeb',
  borderRight: '1px solid #e0e0e0',
  textAlign: 'center',
  background: '#fff5f5',
  verticalAlign: 'middle',
  width: 90,
};

const emptyCellStyle = {
  borderBottom: '1px solid #ebebeb',
  borderRight: '1px solid #e0e0e0',
  background: '#fff',
  minWidth: 120,
};

/**
 * ScheduleGrid component (Requirements 12, 13, 14)
 * 
 * Renders the weekly timetable with:
 * - Simplified color scheme (max 4 colors)
 * - Dark, readable text (min 7:1 contrast)
 * - Bold course codes, 13px min font for room/lecturer
 * - Tooltip on hover for small blocks
 * - Always renders grid structure for consistent layout
 */
export default function ScheduleGrid({ items, week, showStructure }) {
  const filtered = (items || []).filter(it => it.tuan === week);

  const matrix = {};
  filtered.forEach(it => {
    const key = `${it.kip}-${it.ngay}`;
    if (!matrix[key]) matrix[key] = [];
    matrix[key].push(it);
  });

  return (
    <div style={{ overflowX: 'auto' }}>
      <table style={{ width: '100%', borderCollapse: 'collapse', minWidth: 800, tableLayout: 'fixed' }}>
        <colgroup>
          <col style={{ width: 90 }} />
          {NGAY.map(n => <col key={n} />)}
        </colgroup>
        <thead>
          <tr>
            <th style={{ ...thStyle, color: 'var(--color-primary)', borderBottom: '2px solid var(--color-primary)' }}>Kíp</th>
            {NGAY_LABELS.map(l => <th key={l} style={thStyle}>{l}</th>)}
          </tr>
        </thead>
        <tbody>
          {KIPS.map(kip => (
            <tr key={kip} style={{ height: 80 }}>
              <td style={timeCellStyle}>
                <div style={{ fontWeight: 700, color: 'var(--color-primary)', fontSize: 12 }}>
                  {KIP_META[kip].label}
                </div>
                <div style={{ color: '#aaa', fontSize: 10, marginTop: 2 }}>
                  {KIP_META[kip].time}
                </div>
              </td>
              {NGAY.map(ngay => {
                const cells = matrix[`${kip}-${ngay}`] || [];
                if (cells.length === 0) return <td key={ngay} style={emptyCellStyle} />;
                const it = cells[0];
                const color = getClassColor(it);
                const tooltipContent = `${it.monHoc} - Phòng ${it.phong} - GV: ${it.giangVien}`;
                return (
                  <td
                    key={ngay}
                    style={{
                      padding: '8px 10px',
                      border: `1px solid ${color.border}`,
                      background: color.bg,
                      verticalAlign: 'top',
                      minWidth: 120,
                    }}
                  >
                    <Tooltip title={tooltipContent}>
                      <div>
                        {/* Course code: Bold, 14px (Requirement 13) */}
                        <div style={{ 
                          fontWeight: 600, 
                          color: color.text, 
                          fontSize: 14, 
                          lineHeight: 1.3, 
                          marginBottom: 4,
                          fontFamily: 'var(--font-display)'
                        }}>
                          {it.monHoc}
                        </div>
                        {/* LHP name */}
                        <div style={{ fontSize: 12, color: '#1a1a1a', marginBottom: 2 }}>{it.lopHocPhan}</div>
                        {/* Room and lecturer: min 13px (Requirement 13) */}
                        <div style={{ fontSize: 13, color: '#1a1a1a', lineHeight: 1.4 }}>
                          Phòng {it.phong}
                        </div>
                        <div style={{ fontSize: 13, color: '#1a1a1a', lineHeight: 1.4 }}>
                          GV: {it.giangVien}
                        </div>
                      </div>
                    </Tooltip>
                  </td>
                );
              })}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
