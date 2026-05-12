import { useEffect, useState } from 'react';
import { Spin, Alert, Select } from 'antd';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { teacherApi } from '../../../api/endpoints/teacher';
import TeachingScheduleGrid from './TeachingScheduleGrid';
import ErrorBoundary from '../../../components/ErrorBoundary';

function LichDay() {
  const [data, setData] = useState(null);
  const [kiHocId, setKiHocId] = useState(null);
  const [tuan, setTuan] = useState(1);
  const [kyOptions, setKyOptions] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [initError, setInitError] = useState(null);

  useEffect(() => {
    teacherApi.classes()
      .then(rows => {
        const seen = new Set();
        const opts = rows
          .filter(r => { if (seen.has(r.kiHocId)) return false; seen.add(r.kiHocId); return true; })
          .map(r => ({ value: r.kiHocId, label: r.kiHocTen }));
        setKyOptions(opts);
        if (opts.length) setKiHocId(opts[0].value);
      })
      .catch(e => setInitError(e?.response?.data?.error?.message || 'Không thể tải danh sách học kỳ'));
  }, []);

  useEffect(() => {
    if (kiHocId == null) return;
    setLoading(true);
    setError(null);
    teacherApi.schedule(kiHocId)
      .then(d => { setData(d); setTuan(1); })
      .catch(e => setError(e?.response?.data?.error?.message || 'Không thể tải lịch dạy'))
      .finally(() => setLoading(false));
  }, [kiHocId]);

  const maxTuan = (data?.buoi || []).reduce((m, b) => Math.max(m, b.tuan), 1);

  return (
    <div className="fade-in" style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      {initError && <Alert type="error" message={initError} showIcon style={{ marginBottom: 2 }} />}
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
        <Select
          value={kiHocId}
          options={kyOptions}
          onChange={v => { setKiHocId(v); setTuan(1); }}
          style={{ width: 240 }}
          placeholder="Chọn học kỳ"
        />
        {data && (data.buoi || []).length > 0 && (
          <div style={{ marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: 8 }}>
            <button
              onClick={() => setTuan(w => w - 1)}
              disabled={tuan <= 1}
              style={{
                width: 30, height: 30, border: '1px solid #d9d9d9', borderRadius: 4,
                background: tuan <= 1 ? '#f5f5f5' : '#fff',
                cursor: tuan <= 1 ? 'not-allowed' : 'pointer',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: tuan <= 1 ? '#ccc' : '#555',
              }}
            >
              <ChevronLeft size={16} />
            </button>
            <span style={{ minWidth: 80, textAlign: 'center', fontWeight: 600, fontSize: 13, color: '#333' }}>
              Tuần {tuan} / {maxTuan}
            </span>
            <button
              onClick={() => setTuan(w => w + 1)}
              disabled={tuan >= maxTuan}
              style={{
                width: 30, height: 30, border: '1px solid #d9d9d9', borderRadius: 4,
                background: tuan >= maxTuan ? '#f5f5f5' : '#fff',
                cursor: tuan >= maxTuan ? 'not-allowed' : 'pointer',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: tuan >= maxTuan ? '#ccc' : '#555',
              }}
            >
              <ChevronRight size={16} />
            </button>
          </div>
        )}
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: 40 }}><Spin /></div>
      ) : (
        <div style={{ background: '#fff', border: '1px solid var(--color-border)', borderRadius: 6, overflow: 'hidden' }}>
          {!kiHocId ? (
            <div style={{ textAlign: 'center', color: '#999', padding: '40px 0', fontSize: 13 }}>
              Chọn học kỳ để xem lịch dạy
            </div>
          ) : data && (data.buoi || []).length === 0 ? (
            <div style={{ textAlign: 'center', color: '#999', padding: '40px 0', fontSize: 13 }}>
              Không có lịch dạy cho học kỳ này
            </div>
          ) : data ? (
            <TeachingScheduleGrid buoi={data.buoi || []} tuan={tuan} />
          ) : null}
        </div>
      )}
    </div>
  );
}

export default function WrappedLichDay() {
  return (
    <ErrorBoundary>
      <LichDay />
    </ErrorBoundary>
  );
}
