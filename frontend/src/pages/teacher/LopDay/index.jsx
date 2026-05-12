import { useEffect, useState, useMemo } from 'react';
import { Col, Row, Select, Spin, Alert, Input, Card, Badge, Space, Segmented } from 'antd';
import { Search, Filter } from 'lucide-react';
import { teacherApi } from '../../../api/endpoints/teacher';
import ClassCard from './ClassCard';
import ErrorBoundary from '../../../components/ErrorBoundary';

function LopDay() {
  const [classes, setClasses] = useState(null);
  const [kyOptions, setKyOptions] = useState([]);
  const [kiHocId, setKiHocId] = useState(null);
  const [searchText, setSearchText] = useState('');
  const [showEmpty, setShowEmpty] = useState('all');
  const [error, setError] = useState(null);

  useEffect(() => {
    teacherApi.classes()
      .then(rows => {
        setClasses(rows);
        const seen = new Set();
        const opts = rows
          .filter(r => { if (seen.has(r.kiHocId)) return false; seen.add(r.kiHocId); return true; })
          .map(r => ({ value: r.kiHocId, label: r.kiHocTen }));
        setKyOptions(opts);
      })
      .catch(e => {
        setError(e?.response?.data?.error?.message || 'Không thể tải danh sách lớp');
        setClasses([]);
      });
  }, []);

  const filtered = useMemo(() => {
    let list = (classes ?? []);
    if (kiHocId != null) list = list.filter(c => c.kiHocId === kiHocId);
    if (searchText) {
      const s = searchText.toLowerCase();
      list = list.filter(c =>
        c.monHoc?.toLowerCase().includes(s) ||
        c.ten?.toLowerCase().includes(s)
      );
    }
    if (showEmpty === 'active') list = list.filter(c => c.siSo > 0);
    if (showEmpty === 'empty') list = list.filter(c => !c.siSo || c.siSo === 0);
    return list;
  }, [classes, kiHocId, searchText, showEmpty]);

  const totalActive = (classes ?? []).filter(c => (kiHocId == null || c.kiHocId === kiHocId) && c.siSo > 0).length;
  const totalEmpty = (classes ?? []).filter(c => (kiHocId == null || c.kiHocId === kiHocId) && (!c.siSo || c.siSo === 0)).length;

  if (!classes && !error) return <div style={{ textAlign: 'center', padding: 60 }}><Spin /></div>;

  return (
    <div className="fade-in" style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      {error && <Alert type="error" message={error} showIcon />}

      {/* Filter toolbar */}
      <Card size="small" style={{ borderRadius: 10, boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 10, alignItems: 'center' }}>
          <Select
            allowClear
            placeholder="Tất cả kỳ học"
            value={kiHocId}
            onChange={setKiHocId}
            options={kyOptions}
            style={{ width: 220 }}
            suffixIcon={<Filter size={14} />}
          />
          <Input
            placeholder="Tìm tên môn, mã lớp..."
            allowClear
            value={searchText}
            onChange={e => setSearchText(e.target.value)}
            prefix={<Search size={14} style={{ color: '#bbb' }} />}
            style={{ width: 260 }}
          />
          <div style={{ flex: 1 }} />
          <Segmented
            value={showEmpty}
            onChange={setShowEmpty}
            options={[
              { value: 'all', label: `Tất cả (${totalActive + totalEmpty})` },
              { value: 'active', label: `Có SV (${totalActive})` },
              { value: 'empty', label: `Chưa có SV (${totalEmpty})` },
            ]}
            size="small"
          />
        </div>
      </Card>

      {/* Results */}
      {filtered.length === 0 ? (
        <Card style={{ textAlign: 'center', borderRadius: 10 }}>
          <div style={{ color: '#999', padding: '30px 0', fontSize: 14 }}>
            Không tìm thấy lớp học phù hợp
          </div>
        </Card>
      ) : (
        <Row gutter={[14, 14]}>
          {filtered.map(c => (
            <Col key={c.lhpId} xs={24} sm={12} lg={8} xl={6}>
              <ClassCard data={c} />
            </Col>
          ))}
        </Row>
      )}
    </div>
  );
}

export default function WrappedLopDay() {
  return (
    <ErrorBoundary>
      <LopDay />
    </ErrorBoundary>
  );
}
