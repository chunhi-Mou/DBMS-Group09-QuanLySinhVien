import { useEffect, useState, useMemo } from 'react';
import { useParams, useNavigate, useLocation } from 'react-router-dom';
import { Card, Table, Button, Tag, Space, Select, Input, message, Popconfirm, Empty, Spin, Badge, Statistic, Row, Col } from 'antd';
import { ArrowLeft, Plus, Trash2, BookOpen, Download, Save, ClipboardList, Package, ArrowRight } from 'lucide-react';
import { adminApi } from '../../../api/endpoints/admin';
import * as XLSX from 'xlsx';

const LOAI_COLOR = { BB: 'red', TC: 'green' };
const LOAI_LABEL = { BB: 'Bắt buộc', TC: 'Tự chọn' };

export default function CurriculumBuilder() {
  const { nganhId } = useParams();
  const navigate = useNavigate();
  const location = useLocation();
  const nganhTen = location.state?.nganhTen ?? `Ngành #${nganhId}`;

  const [allMon, setAllMon] = useState([]);
  const [assigned, setAssigned] = useState([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [addingMonId, setAddingMonId] = useState(null);
  const [addingLoai, setAddingLoai] = useState('BB');
  const [searchPool, setSearchPool] = useState('');
  const [searchAssigned, setSearchAssigned] = useState('');

  const load = async () => {
    setLoading(true);
    const [mon, rows] = await Promise.all([adminApi.monHocs(), adminApi.getNganhMon(Number(nganhId))]);
    setAllMon(mon);
    setAssigned(rows.map(r => ({ ...r, monHocId: r.monHocId })));
    setLoading(false);
  };
  useEffect(() => { load(); }, [nganhId]);

  /* Enrich assigned with full subject info */
  const assignedEnriched = useMemo(() => {
    return assigned.map(a => {
      const mon = allMon.find(m => m.id === a.monHocId);
      return { ...a, mamh: mon?.mamh ?? '', ten: mon?.ten ?? `#${a.monHocId}`, sotc: mon?.sotc ?? 0, mota: mon?.mota ?? '' };
    });
  }, [assigned, allMon]);

  /* Stats */
  const totalTC_BB = assignedEnriched.filter(a => a.loai === 'BB').reduce((s, a) => s + (a.sotc || 0), 0);
  const totalTC_TC = assignedEnriched.filter(a => a.loai === 'TC').reduce((s, a) => s + (a.sotc || 0), 0);
  const totalTC = totalTC_BB + totalTC_TC;

  /* Pool = all subjects not yet assigned */
  const pool = useMemo(() => {
    const ids = new Set(assigned.map(a => a.monHocId));
    let list = allMon.filter(m => !ids.has(m.id));
    if (searchPool) {
      const s = searchPool.toLowerCase();
      list = list.filter(m => m.ten?.toLowerCase().includes(s) || m.mamh?.toLowerCase().includes(s));
    }
    return list;
  }, [allMon, assigned, searchPool]);

  const filteredAssigned = useMemo(() => {
    if (!searchAssigned) return assignedEnriched;
    const s = searchAssigned.toLowerCase();
    return assignedEnriched.filter(a => a.ten?.toLowerCase().includes(s) || a.mamh?.toLowerCase().includes(s));
  }, [assignedEnriched, searchAssigned]);

  /* Actions */
  const addSubject = (monHocId, loai) => {
    if (assigned.find(a => a.monHocId === monHocId)) return;
    setAssigned(prev => [...prev, { monHocId, loai: loai || 'BB' }]);
  };

  const removeSubject = (monHocId) => {
    setAssigned(prev => prev.filter(a => a.monHocId !== monHocId));
  };

  const changeLoai = (monHocId, loai) => {
    setAssigned(prev => prev.map(a => a.monHocId === monHocId ? { ...a, loai } : a));
  };

  const saveAll = async () => {
    setSaving(true);
    try {
      const items = assigned.map(a => ({ monHocId: a.monHocId, loai: a.loai ?? 'BB' }));
      await adminApi.setNganhMon(Number(nganhId), items);
      message.success(`Đã lưu ${items.length} môn cho ngành "${nganhTen}"`);
    } catch (e) {
      message.error(e?.response?.data?.error?.message ?? 'Lỗi khi lưu');
    }
    setSaving(false);
  };

  const exportCurriculum = () => {
    const data = assignedEnriched.map((a, i) => ({
      'STT': i + 1,
      'Mã MH': a.mamh,
      'Tên môn': a.ten,
      'Số TC': a.sotc,
      'Loại': LOAI_LABEL[a.loai] ?? a.loai,
    }));
    const ws = XLSX.utils.json_to_sheet(data);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'CTDT');
    XLSX.writeFile(wb, `ctdt_${nganhTen.replace(/\s/g, '_')}.xlsx`);
  };

  if (loading) return <Spin style={{ display: 'block', margin: '80px auto' }} />;

  return (
    <div className="fade-in" style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      {/* Header */}
      <Card size="small" style={{ borderRadius: 10, boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
          <Button icon={<ArrowLeft size={14} />} onClick={() => navigate('/admin/nganh-monhoc')}>Quay lại</Button>
          <div style={{ fontSize: 18, fontWeight: 700, color: '#1f1f1f' }}>
            <BookOpen size={18} style={{ marginRight: 8, verticalAlign: -3, color: '#1677ff' }} />
            Chương trình đào tạo — {nganhTen}
          </div>
          <div style={{ flex: 1 }} />
          <Button icon={<Download size={14} />} onClick={exportCurriculum}>Xuất Excel</Button>
          <Button type="primary" loading={saving} onClick={saveAll} style={{ fontWeight: 600 }} icon={<Save size={14} />}>
            Lưu chương trình
          </Button>
        </div>
      </Card>

      {/* Stats */}
      <Row gutter={[12, 12]}>
        <Col xs={8}>
          <Card size="small" style={{ borderRadius: 10, textAlign: 'center', borderTop: '3px solid #1677ff' }}>
            <Statistic title={<span style={{ fontWeight: 600, color: '#555' }}>Tổng tín chỉ</span>} value={totalTC} valueStyle={{ fontSize: 28, fontWeight: 700, color: '#1677ff' }} />
          </Card>
        </Col>
        <Col xs={8}>
          <Card size="small" style={{ borderRadius: 10, textAlign: 'center', borderTop: '3px solid #f5222d' }}>
            <Statistic title={<span style={{ fontWeight: 600, color: '#555' }}>Bắt buộc</span>} value={totalTC_BB} suffix="TC" valueStyle={{ fontSize: 24, fontWeight: 700, color: '#f5222d' }} />
          </Card>
        </Col>
        <Col xs={8}>
          <Card size="small" style={{ borderRadius: 10, textAlign: 'center', borderTop: '3px solid #52c41a' }}>
            <Statistic title={<span style={{ fontWeight: 600, color: '#555' }}>Tự chọn</span>} value={totalTC_TC} suffix="TC" valueStyle={{ fontSize: 24, fontWeight: 700, color: '#52c41a' }} />
          </Card>
        </Col>
      </Row>

      {/* Main content: assigned + pool side by side */}
      <div style={{ display: 'flex', gap: 14 }}>
        {/* Assigned subjects */}
        <Card size="small" style={{ flex: 2, borderRadius: 10, boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}
          title={<span style={{ fontWeight: 600 }}><ClipboardList size={14} style={{ marginRight: 6, verticalAlign: -2 }} />Môn trong chương trình ({assignedEnriched.length} môn)</span>}
          extra={<Input.Search placeholder="Tìm môn..." allowClear onChange={e => setSearchAssigned(e.target.value)} style={{ width: 200 }} size="small" />}
        >
          {filteredAssigned.length === 0 ? (
            <Empty description={<span>Chưa gán môn nào. Thêm môn từ danh sách bên phải <ArrowRight size={12} style={{ verticalAlign: -2 }} /></span>} />
          ) : (
            <Table
              size="small"
              rowKey="monHocId"
              dataSource={filteredAssigned}
              pagination={false}
              scroll={{ y: 460 }}
              columns={[
                { title: 'Mã MH', dataIndex: 'mamh', width: 90, render: v => <span style={{ fontWeight: 600, fontFamily: 'monospace' }}>{v}</span> },
                { title: 'Tên môn', dataIndex: 'ten', ellipsis: true },
                { title: 'TC', dataIndex: 'sotc', width: 50, align: 'center', render: v => <span style={{ fontWeight: 700 }}>{v}</span> },
                {
                  title: 'Loại', width: 130, render: (_, r) => (
                    <Select
                      value={r.loai ?? 'BB'}
                      onChange={v => changeLoai(r.monHocId, v)}
                      options={[{ value: 'BB', label: <span><span style={{ display: 'inline-block', width: 8, height: 8, borderRadius: '50%', background: '#f5222d', marginRight: 6, verticalAlign: 0 }} />Bắt buộc</span> }, { value: 'TC', label: <span><span style={{ display: 'inline-block', width: 8, height: 8, borderRadius: '50%', background: '#52c41a', marginRight: 6, verticalAlign: 0 }} />Tự chọn</span> }]}
                      size="small"
                      style={{ width: '100%' }}
                    />
                  )
                },
                {
                  title: '', width: 50, render: (_, r) => (
                    <Popconfirm title="Gỡ môn này?" onConfirm={() => removeSubject(r.monHocId)} okText="Gỡ" cancelText="Hủy">
                      <Button size="small" danger type="text" icon={<Trash2 size={14} />} />
                    </Popconfirm>
                  )
                },
              ]}
            />
          )}
        </Card>

        {/* Available pool */}
        <Card size="small" style={{ flex: 1, borderRadius: 10, boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}
          title={<span style={{ fontWeight: 600 }}><Package size={14} style={{ marginRight: 6, verticalAlign: -2 }} />Kho môn học ({pool.length})</span>}
          extra={<Input.Search placeholder="Tìm..." allowClear onChange={e => setSearchPool(e.target.value)} style={{ width: 160 }} size="small" />}
        >
          <div style={{ maxHeight: 500, overflowY: 'auto' }}>
            {pool.length === 0 ? (
              <Empty description="Tất cả môn đã được gán" image={Empty.PRESENTED_IMAGE_SIMPLE} />
            ) : (
              pool.map(m => (
                <div key={m.id} style={{
                  display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                  padding: '6px 8px', borderBottom: '1px solid #f5f5f5',
                  transition: 'background 0.15s',
                  cursor: 'pointer',
                }}
                onMouseEnter={e => e.currentTarget.style.background = '#f0f5ff'}
                onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
                >
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: 13, fontWeight: 600, color: '#333', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {m.ten}
                    </div>
                    <div style={{ fontSize: 11, color: '#888' }}>
                      {m.mamh && <span style={{ fontFamily: 'monospace' }}>{m.mamh}</span>}
                      {m.mamh && ' · '}{m.sotc} TC
                    </div>
                  </div>
                  <Button
                    size="small"
                    type="primary"
                    ghost
                    icon={<Plus size={12} />}
                    onClick={() => addSubject(m.id, 'BB')}
                    style={{ flexShrink: 0, marginLeft: 8 }}
                  >
                    Thêm
                  </Button>
                </div>
              ))
            )}
          </div>
        </Card>
      </div>
    </div>
  );
}
