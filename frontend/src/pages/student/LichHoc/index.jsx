import { useEffect, useState } from 'react';
import { Spin, Alert } from 'antd';
import { ChevronLeft, ChevronRight, Calendar } from 'lucide-react';
import SemesterSelect from '../DangKyTinChi/components/SemesterSelect';
import { studentApi } from '../../../api/endpoints/student';
import ScheduleGrid from './ScheduleGrid';
import EmptyState from '../../../components/EmptyState';

export default function LichHoc() {
  const [kiHocId, setKiHocId] = useState();
  const [items, setItems] = useState([]);
  const [week, setWeek] = useState(1);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!kiHocId) return;
    setLoading(true);
    setError(null);
    studentApi.schedule(kiHocId)
      .then(d => { setItems(d.items || []); setWeek(1); })
      .catch(e => setError(e?.response?.data?.error?.message || 'Không thể tải lịch học'))
      .finally(() => setLoading(false));
  }, [kiHocId]);

  const tuanMax = items.reduce((m, i) => Math.max(m, i.tuan), 1);
  const weekItems = items.filter(it => it.tuan === week);

  return (
    <div className="fade-in" style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      {error && <Alert type="error" message={error} showIcon style={{ marginBottom: 2 }} />}

      <div style={{
        background: '#fff',
        border: '1px solid var(--color-border)',
        borderRadius: 6,
        padding: '10px 16px',
        display: 'flex',
        alignItems: 'center',
        gap: 12,
      }}>
        <span style={{ fontWeight: 600, color: '#555', fontSize: 13 }}>Học kỳ</span>
        <SemesterSelect value={kiHocId} onChange={setKiHocId} />
        {kiHocId && (
          <div style={{ marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: 8 }}>
            <button
              onClick={() => setWeek(w => w - 1)}
              disabled={week <= 1}
              style={{
                width: 30, height: 30, border: '1px solid #d9d9d9', borderRadius: 4,
                background: week <= 1 ? '#f5f5f5' : '#fff',
                cursor: week <= 1 ? 'not-allowed' : 'pointer',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: week <= 1 ? '#ccc' : '#555',
              }}
            >
              <ChevronLeft size={16} />
            </button>
            <span style={{ minWidth: 80, textAlign: 'center', fontWeight: 600, fontSize: 13, color: '#333' }}>
              Tuần {week} / {tuanMax}
            </span>
            <button
              onClick={() => setWeek(w => w + 1)}
              disabled={week >= tuanMax}
              style={{
                width: 30, height: 30, border: '1px solid #d9d9d9', borderRadius: 4,
                background: week >= tuanMax ? '#f5f5f5' : '#fff',
                cursor: week >= tuanMax ? 'not-allowed' : 'pointer',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: week >= tuanMax ? '#ccc' : '#555',
              }}
            >
              <ChevronRight size={16} />
            </button>
          </div>
        )}
      </div>

      {/* Schedule (Requirement 14: always show grid structure) */}
      {loading ? (
        <div style={{ textAlign: 'center', padding: 40 }}><Spin /></div>
      ) : (
        <div style={{ background: '#fff', border: '1px solid var(--color-border)', borderRadius: 6, overflow: 'hidden', position: 'relative' }}>
          {!kiHocId ? (
            <div style={{ textAlign: 'center', color: '#999', padding: '40px 0', fontSize: 13 }}>
              Chọn học kỳ để xem lịch học
            </div>
          ) : (
            <>
              {/* Always render the grid structure */}
              <ScheduleGrid items={items} week={week} />
              
              {/* Overlay empty state message when no classes this week */}
              {weekItems.length === 0 && (
                <div style={{
                  position: 'absolute',
                  top: '50%',
                  left: '50%',
                  transform: 'translate(-50%, -50%)',
                  textAlign: 'center',
                  background: 'rgba(255, 255, 255, 0.95)',
                  padding: '24px 32px',
                  borderRadius: 8,
                  boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
                  zIndex: 10,
                }}>
                  <EmptyState 
                    message="No classes scheduled for this week"
                    icon={<Calendar size={48} />}
                  />
                </div>
              )}
            </>
          )}
        </div>
      )}
    </div>
  );
}
