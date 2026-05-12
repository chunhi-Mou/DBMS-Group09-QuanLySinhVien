import { useMemo } from 'react';

const DAYS = [1, 2, 3, 4, 5, 6];
const DAY_SHORT = { 1: 'T2', 2: 'T3', 3: 'T4', 4: 'T5', 5: 'T6', 6: 'T7' };
const KIPS = [1, 2, 3, 4, 5, 6];
const KIP_TIME = {
  1: '07-08:50', 2: '09-10:50', 3: '12-13:50',
  4: '14-15:50', 5: '16-17:50', 6: '18-19:50',
};

export default function MiniSchedule({ registered = [], pending = [] }) {
  const slotMap = useMemo(() => {
    const map = new Map();
    const addSlots = (lhps, type) => {
      for (const lhp of lhps) {
        const seen = new Set();
        for (const b of lhp.lich || []) {
          const key = `${b.ngay}-${b.kip}`;
          if (seen.has(key)) continue;
          seen.add(key);
          if (!map.has(key)) map.set(key, { reg: 0, pend: 0, name: '' });
          const slot = map.get(key);
          slot[type]++;
          if (!slot.name) slot.name = lhp.monHocId || '';
        }
      }
    };
    addSlots(registered, 'reg');
    addSlots(pending, 'pend');
    return map;
  }, [registered, pending]);

  return (
    <div style={{ userSelect: 'none' }}>
      <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 12 }}>
        <thead>
          <tr>
            <th style={{ width: 56, textAlign: 'left', padding: '4px 4px 8px', color: '#999', fontWeight: 400, fontSize: 11 }}>
              Kíp
            </th>
            {DAYS.map(d => (
              <th key={d} style={{ padding: '4px 2px 8px', textAlign: 'center', color: '#555', fontWeight: 600, fontSize: 12 }}>
                {DAY_SHORT[d]}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {KIPS.map(kip => (
            <tr key={kip}>
              <td style={{ padding: '3px 4px 3px 0', verticalAlign: 'middle' }}>
                <div style={{ fontSize: 11, color: '#aaa', lineHeight: 1.3 }}>
                  <span style={{ fontWeight: 600, color: '#666' }}>{kip}</span>
                  <br />
                  <span style={{ fontSize: 10 }}>{KIP_TIME[kip]}</span>
                </div>
              </td>
              {DAYS.map(ngay => {
                const slot = slotMap.get(`${ngay}-${kip}`);
                const regCount = slot?.reg || 0;
                const pendCount = slot?.pend || 0;
                const total = regCount + pendCount;
                const isConflict = total > 1;
                const isPend = !isConflict && pendCount > 0;
                const isReg = !isConflict && regCount > 0;

                let bg = '#f5f5f5';
                let border = '1px solid #e8e8e8';
                let textColor = 'transparent';
                let label = '';

                if (isConflict) { bg = '#ff4d4f'; border = '1px solid #cf1322'; textColor = '#fff'; label = '!'; }
                else if (isPend) { bg = '#1677ff'; border = '1px solid #0958d9'; textColor = '#fff'; label = slot?.name || ''; }
                else if (isReg) { bg = 'var(--color-primary)'; border = '1px solid var(--color-primary-dark)'; textColor = '#fff'; label = slot?.name || ''; }

                return (
                  <td key={ngay} style={{ padding: 2 }}>
                    <div style={{
                      minHeight: 36, 
                      minWidth: 36,
                      borderRadius: 3,
                      background: bg, border,
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      fontSize: 10,
                      color: textColor,
                      fontWeight: isConflict ? 700 : 500,
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                      whiteSpace: 'nowrap',
                      padding: '2px 3px',
                    }}>
                      {(isConflict || isPend || isReg) && (
                        <span style={{ lineHeight: 1, fontSize: isConflict ? 12 : 10 }}>
                          {isConflict ? '!' : label}
                        </span>
                      )}
                    </div>
                  </td>
                );
              })}
            </tr>
          ))}
        </tbody>
      </table>

      <div style={{ marginTop: 10, display: 'flex', gap: 10, flexWrap: 'wrap' }}>
        {[
          { color: 'var(--color-primary)', label: 'Đã đăng ký' },
          { color: '#1677ff', label: 'Chờ xác nhận' },
          { color: '#ff4d4f', label: 'Trùng lịch' },
        ].map(({ color, label }) => (
          <div key={label} style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 10, color: '#666' }}>
            <div style={{ width: 10, height: 10, borderRadius: 2, background: color, flexShrink: 0 }} />
            {label}
          </div>
        ))}
      </div>
    </div>
  );
}
