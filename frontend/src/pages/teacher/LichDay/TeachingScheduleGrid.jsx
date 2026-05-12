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

const PALETTE = [
  '#ffd6d6', '#d6eaff', '#d6ffd6', '#fff3d6',
  '#e8d6ff', '#d6fff8', '#ffecd6', '#d6f5d6',
];
const PALETTE_BORDER = [
  '#ffb3b3', '#b3d4ff', '#b3ffb3', '#ffe8a3',
  '#d4b3ff', '#b3fff2', '#ffd9a3', '#b3e8b3',
];
const PALETTE_TEXT = [
  '#8b0000', '#003d99', '#006600', '#7a5500',
  '#5c0099', '#005c4d', '#7a4000', '#005500',
];

function colorIdx(name) {
  let h = 0;
  for (const c of (name || '')) h = (h * 31 + c.charCodeAt(0)) & 0xffff;
  return h % PALETTE.length;
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

export default function TeachingScheduleGrid({ buoi, tuan }) {
  const filtered = (buoi || []).filter(b => b.tuan === tuan);

  const matrix = {};
  filtered.forEach(b => {
    const key = `${b.kip}-${b.ngay}`;
    if (!matrix[key]) matrix[key] = [];
    matrix[key].push(b);
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
                const idx = colorIdx(it.lopHocPhan);
                return (
                  <td
                    key={ngay}
                    style={{
                      padding: '8px 10px',
                      border: `1px solid ${PALETTE_BORDER[idx]}`,
                      background: PALETTE[idx],
                      verticalAlign: 'top',
                      minWidth: 120,
                    }}
                  >
                    <div style={{ fontWeight: 700, color: PALETTE_TEXT[idx], fontSize: 12, lineHeight: 1.3, marginBottom: 3 }}>
                      {it.monHoc}
                    </div>
                    <div style={{ fontSize: 11, color: '#444', marginBottom: 2 }}>{it.lopHocPhan}</div>
                    <div style={{ fontSize: 11, color: '#555' }}>Phòng {it.phong}</div>
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
