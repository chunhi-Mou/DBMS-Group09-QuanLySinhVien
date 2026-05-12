import { useState, useEffect } from 'react';
import { Table, Button, Tag, Input, message, Modal, Popconfirm, Spin, Alert } from 'antd';
import { Search, Trash2 } from 'lucide-react';
import MiniSchedule from './components/MiniSchedule';
import { useRegistration } from './hooks/useRegistration';
import http from '../../../api/axios';

const NGAY_SHORT = { 1: 'T2', 2: 'T3', 3: 'T4', 4: 'T5', 5: 'T6', 6: 'T7' };
const NGAY_FULL = { 1: 'Thứ 2', 2: 'Thứ 3', 3: 'Thứ 4', 4: 'Thứ 5', 5: 'Thứ 6', 6: 'Thứ 7' };
const KIP_TIME = {
  1: '07:00-08:50', 2: '09:00-10:50', 3: '12:00-13:50',
  4: '14:00-15:50', 5: '16:00-17:50', 6: '18:00-19:50',
};

function lichText(lich = []) {
  if (!lich.length) return '';
  const b = lich[0];
  return `${NGAY_FULL[b.ngay] ?? `Ngày ${b.ngay}`}, ${KIP_TIME[b.kip] ?? `Kíp ${b.kip}`}`;
}

function FilterBtn({ label, active, onClick }) {
  return (
    <button onClick={onClick} style={{
      padding: '2px 9px', borderRadius: 4, cursor: 'pointer', fontSize: 12, lineHeight: '22px',
      border: active ? '1px solid var(--color-primary)' : '1px solid #d9d9d9',
      background: active ? 'var(--color-primary)' : '#fff',
      color: active ? '#fff' : '#555',
      fontWeight: active ? 600 : 400,
      transition: 'all 120ms',
    }}>
      {label}
    </button>
  );
}

const PILL_CONFIRMED = { padding: '2px 10px', borderRadius: 4, fontSize: 12, fontWeight: 500, background: '#F6FFED', border: '1px solid #B7EB8F', color: '#237804' };
const PILL_PENDING   = { padding: '2px 10px', borderRadius: 4, fontSize: 12, fontWeight: 500, background: '#E6F4FF', border: '1px solid #91CAFF', color: '#0958D9' };
const PILL_FULL      = { padding: '2px 10px', borderRadius: 4, fontSize: 12, fontWeight: 500, background: '#FFF7E6', border: '1px solid #FFD591', color: '#873800' };

export default function DangKyTinChi() {
  const [kiHocId, setKiHocId] = useState();
  const [kiHocTen, setKiHocTen] = useState('');
  const [loadingKiHoc, setLoadingKiHoc] = useState(true);
  const [search, setSearch] = useState('');
  const [filterNgay, setFilterNgay] = useState(new Set());
  const [filterLoai, setFilterLoai] = useState('');
  const [filterMonId, setFilterMonId] = useState(null);
  const [submitting, setSubmitting] = useState(false);
  const reg = useRegistration(kiHocId);

  // Fetch active semester on mount
  useEffect(() => {
    const fetchActiveSemester = async () => {
      try {
        setLoadingKiHoc(true);
        const response = await http.get('/kihoc');
        const semesters = response.data.data;
        
        if (semesters && semesters.length > 0) {
          // The first semester is the most recent (active) one since they're ordered by ID DESC
          const activeSemester = semesters[0];
          setKiHocId(activeSemester.id);
          setKiHocTen(activeSemester.ten);
        }
      } catch (error) {
        message.error('Không thể tải thông tin học kỳ');
      } finally {
        setLoadingKiHoc(false);
      }
    };

    fetchActiveSemester();
  }, []);

  const allLhp = reg.available.lopHocPhans || [];
  const available = allLhp.filter(l => !l.daDangKy);
  const registered = allLhp.filter(l => l.daDangKy);
  const pending = available.filter(l => reg.selectedIds.has(l.id));

  const registeredTc = registered.reduce((s, l) => s + (l.soTc || 0), 0);
  const pendingTc = pending.reduce((s, l) => s + (l.soTc || 0), 0);
  const totalTc = registeredTc + pendingTc;

  const toggleNgay = (d) => {
    const next = new Set(filterNgay);
    next.has(d) ? next.delete(d) : next.add(d);
    setFilterNgay(next);
  };

  const hasFilter = search || filterNgay.size || filterLoai || filterMonId;
  const clearFilters = () => { setSearch(''); setFilterNgay(new Set()); setFilterLoai(''); setFilterMonId(null); };

  const shown = available.filter(l => {
    if (search) {
      const q = search.toLowerCase();
      if (!l.monHocTen.toLowerCase().includes(q) && !l.ten.toLowerCase().includes(q)) return false;
    }
    if (filterNgay.size > 0 && !l.lich.some(b => filterNgay.has(b.ngay))) return false;
    if (filterLoai && l.loai !== filterLoai) return false;
    if (filterMonId && l.monHocId !== filterMonId) return false;
    return true;
  });

  const submit = async () => {
    if (reg.selectedIds.size === 0) return;
    setSubmitting(true);
    try {
      const res = await reg.submit();
      if (res.failed?.length) {
        Modal.warning({
          title: 'Một số lớp không thể đăng ký',
          content: <ul>{res.failed.map(f => <li key={f.lhpId}>LHP #{f.lhpId}: {f.lyDo}</li>)}</ul>,
        });
      } else {
        message.success(`Đã đăng ký ${res.success.length} lớp`);
      }
    } catch (e) {
      message.error(e.response?.data?.error?.message || 'Lỗi');
    } finally { setSubmitting(false); }
  };

  // Row styling for emphasis (Requirement 11)
  const getRowClassName = (record, index) => {
    if (record.daPass) return 'reg-row-passed';
    if (record.daDay) return 'reg-row-full';
    return index % 2 === 0 ? 'reg-row-even' : 'reg-row-odd';
  };

  const getRowProps = (record) => {
    const baseStyle = {};
    if (record.daPass) baseStyle.opacity = 0.5;
    else if (record.daDay) baseStyle.opacity = 0.6;
    return { style: baseStyle };
  };

  const availableCols = [
    { title: 'Mã MH', dataIndex: 'monHocId', width: 90 },
    {
      title: 'Tên môn học', dataIndex: 'monHocTen',
      render: (v) => <span style={{ fontWeight: 600 }}>{v}</span>,
    },
    { title: 'Nhóm', dataIndex: 'nhom', width: 60, align: 'center' },
    { title: 'Tổ', dataIndex: 'toThucHanh', width: 50, align: 'center' },
    { title: 'Số TC', dataIndex: 'soTc', width: 60, align: 'center' },
    { title: 'Lớp', width: 50, align: 'center', render: () => '*' },
    { 
      title: 'Sĩ số', width: 100, align: 'center',
      render: (_, r) => {
        const current = r.siSoHienTai || 0;
        const max = r.siSoToiDa || 0;
        const isFull = r.daDay;
        return (
          <span style={{ 
            fontWeight: 600, 
            fontSize: 13,
            fontFamily: 'var(--font-data)',
            color: isFull ? '#f5222d' : current >= max * 0.9 ? '#fa8c16' : '#333'
          }}>
            {current}/{max}
          </span>
        );
      }
    },
    {
      title: '', width: 115,
      render: (_, r) => {
        if (r.daDay) {
          const altCount = available.filter(l => l.monHocId === r.monHocId && !l.daDay && l.id !== r.id).length;
          return (
            <div>
              <span style={PILL_FULL}>Hết chỗ</span>
              {altCount > 0 && (
                <div>
                  <button onClick={() => setFilterMonId(r.monHocId)} style={{
                    border: 'none', background: 'none', color: 'var(--color-primary)',
                    fontSize: 11, cursor: 'pointer', padding: 0, textDecoration: 'underline',
                  }}>
                    Xem {altCount} lớp khác
                  </button>
                </div>
              )}
            </div>
          );
        }
        if (r.daPass) return <span style={{ color: '#999', fontSize: 12 }}>Đã qua</span>;

        const conflicts = reg.conflictsFor(r).length;
        const selected = reg.selectedIds.has(r.id);
        const canSelect = reg.tickable(r);

        if (!canSelect && !selected) {
          return (
            <span style={{ color: '#faad14', fontSize: 11 }}>
              {conflicts > 0 ? `Trùng ${conflicts} buổi` : 'Đã chọn môn này'}
            </span>
          );
        }

        return (
          <Button
            size="small"
            type={selected ? 'default' : 'primary'}
            danger={selected}
            onClick={() => reg.toggle(r)}
            style={!selected ? { 
              background: 'var(--color-primary)', 
              borderColor: 'var(--color-primary)',
              fontWeight: 500
            } : {
              fontWeight: 500
            }}
          >
            {selected ? 'Bỏ chọn' : 'Đăng ký'}
          </Button>
        );
      },
    },
  ];

  const unifiedCols = [
    {
      title: '', width: 40,
      render: (_, r) => r.daDangKy
        ? (
          <Popconfirm title="Hủy đăng ký môn này?" onConfirm={() => reg.toggle(r)}>
            <Button size="small" danger icon={<Trash2 size={12} />} />
          </Popconfirm>
        )
        : <Button size="small" onClick={() => reg.toggle(r)} icon={<Trash2 size={12} />} />,
    },
    { title: 'Mã MH', dataIndex: 'monHocId', width: 90 },
    {
      title: 'Tên môn học', dataIndex: 'monHocTen',
      render: (v) => <span style={{ fontWeight: 500 }}>{v}</span>,
    },
    { 
      title: 'Nhóm tổ', width: 80, align: 'center',
      render: (_, r) => `${r.nhom || ''}${r.toThucHanh ? ' - ' + r.toThucHanh : ''}`
    },
    { title: 'Số TC', dataIndex: 'soTc', width: 60, align: 'center' },
    { title: 'Lớp', width: 50, align: 'center', render: () => '*' },
    { 
      title: 'Ngày đăng ký', dataIndex: 'ngayDangKy', width: 120, 
      render: (v) => v ? new Date(v).toLocaleDateString('vi-VN') : ''
    },
    {
      title: 'Trạng thái', width: 130,
      render: (_, r) => r.daDangKy
        ? <span style={PILL_CONFIRMED}>Đã đăng ký</span>
        : <span style={PILL_PENDING}>Chờ xác nhận</span>,
    },
  ];

  const allChosen = [...registered, ...pending];
  const bbTc = allChosen.filter(l => l.loai === 'BB').reduce((s, l) => s + (l.soTc || 0), 0);
  const tcTc = allChosen.filter(l => l.loai === 'TC').reduce((s, l) => s + (l.soTc || 0), 0);

  return (
    <div className="fade-in" style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      {reg.error && <Alert type="error" message={reg.error} showIcon style={{ marginBottom: 2 }} />}

      {/* Semester bar - Display active semester only */}
      <div style={{ background: '#fff', border: '1px solid var(--color-border)', borderRadius: 6, padding: '10px 16px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <span style={{ fontWeight: 600, color: '#555', fontSize: 13 }}>Học kỳ hiện tại</span>
        {loadingKiHoc ? (
          <Spin size="small" />
        ) : (
          <span style={{ color: '#333', fontSize: 14, fontWeight: 500 }}>{kiHocTen}</span>
        )}
      </div>

      {loadingKiHoc ? (
        <div style={{ textAlign: 'center', padding: 40 }}><Spin /></div>
      ) : reg.loading ? (
        <div style={{ textAlign: 'center', padding: 40 }}><Spin /></div>
      ) : (
        <>
          {/* Main 2-column layout (Requirement 9: 1.4fr 0.6fr) */}
          <div style={{ display: 'grid', gridTemplateColumns: '1.4fr 0.6fr', gap: 14, alignItems: 'start' }}>
            {/* Left: available LHPs */}
            <div style={{ background: '#fff', border: '1px solid var(--color-border)', borderRadius: 6, overflow: 'hidden' }}>
              <div style={{ padding: '12px 14px', borderBottom: '1px solid var(--color-border)' }}>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
                  <span style={{ fontWeight: 600, fontSize: 14 }}>Danh sách môn học mở</span>
                  <Input
                    prefix={<Search size={13} style={{ color: '#bbb' }} />}
                    placeholder="Tìm môn hoặc mã LHP"
                    value={search}
                    onChange={e => setSearch(e.target.value)}
                    style={{ width: 210 }}
                    allowClear
                    size="small"
                  />
                </div>
                <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap', alignItems: 'center' }}>
                  <span style={{ fontSize: 11, color: '#aaa', marginRight: 2 }}>Ngày học</span>
                  {[1, 2, 3, 4, 5, 6].map(d => (
                    <FilterBtn key={d} label={NGAY_SHORT[d]} active={filterNgay.has(d)} onClick={() => toggleNgay(d)} />
                  ))}
                  <span style={{ fontSize: 11, color: '#aaa', marginLeft: 6, marginRight: 2 }}>Loại</span>
                  {['BB', 'TC'].map(l => (
                    <FilterBtn key={l} label={l} active={filterLoai === l} onClick={() => setFilterLoai(filterLoai === l ? '' : l)} />
                  ))}
                  {hasFilter && (
                    <button onClick={clearFilters} style={{ border: 'none', background: 'none', color: '#aaa', fontSize: 11, cursor: 'pointer', textDecoration: 'underline', marginLeft: 4 }}>
                      Xóa lọc
                    </button>
                  )}
                </div>
                {filterMonId && (
                  <div style={{ marginTop: 8, display: 'flex', alignItems: 'center', gap: 8, padding: '4px 10px', background: 'var(--color-primary-light)', borderRadius: 4, fontSize: 12 }}>
                    <span style={{ color: 'var(--color-primary)' }}>
                      Lọc theo môn: <strong>{available.find(l => l.monHocId === filterMonId)?.monHocTen || registered.find(l => l.monHocId === filterMonId)?.monHocTen || 'môn đã chọn'}</strong>
                    </span>
                    <button onClick={() => setFilterMonId(null)} style={{ border: 'none', background: 'none', color: 'var(--color-primary)', fontWeight: 700, cursor: 'pointer', padding: 0, fontSize: 14, lineHeight: 1 }}>
                      ×
                    </button>
                  </div>
                )}
              </div>
              <Table
                rowKey="id"
                size="middle"
                dataSource={shown}
                columns={availableCols}
                pagination={{ pageSize: 12, showSizeChanger: false, size: 'small' }}
                locale={{ emptyText: kiHocId ? 'Không có môn học phù hợp' : 'Chọn học kỳ để xem danh sách' }}
                rowClassName={getRowClassName}
                onRow={getRowProps}
              />
            </div>

            {/* Right sidebar */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              <div style={{ background: '#fff', border: '1px solid var(--color-border)', borderRadius: 6, padding: 14 }}>
                <div style={{ fontWeight: 600, fontSize: 13, marginBottom: 12, color: '#333' }}>Lịch học tổng quan</div>
                <MiniSchedule registered={registered} pending={pending} />
              </div>

              <div style={{ background: '#fff', border: '1px solid var(--color-border)', borderRadius: 6, padding: 14 }}>
                <div style={{ fontWeight: 600, fontSize: 13, marginBottom: 12, color: '#333' }}>Tín chỉ học kỳ này</div>
                <div style={{ display: 'flex', alignItems: 'baseline', gap: 6, marginBottom: 4 }}>
                  <span style={{ fontSize: 32, fontWeight: 700, color: 'var(--color-primary)', lineHeight: 1, fontFamily: 'var(--font-data)' }}>{totalTc}</span>
                  <span style={{ fontSize: 12, color: '#888' }}>tín chỉ</span>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 5, marginTop: 8 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12 }}>
                    <span style={{ color: '#555' }}>Đã xác nhận</span>
                    <span style={{ fontWeight: 600 }}>{registeredTc} TC</span>
                  </div>
                  {pendingTc > 0 && (
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12 }}>
                      <span style={{ color: '#1677ff' }}>Chờ xác nhận</span>
                      <span style={{ fontWeight: 600, color: '#1677ff' }}>+{pendingTc} TC</span>
                    </div>
                  )}
                  {allChosen.length > 0 && (
                    <div style={{ marginTop: 6, paddingTop: 8, borderTop: '1px solid #f0f0f0', display: 'flex', flexDirection: 'column', gap: 4 }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 11, color: '#888' }}>
                        <span>Bắt buộc (BB)</span>
                        <span style={{ fontWeight: 500, color: '#555' }}>{bbTc} TC</span>
                      </div>
                      <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 11, color: '#888' }}>
                        <span>Tự chọn (TC)</span>
                        <span style={{ fontWeight: 500, color: '#555' }}>{tcTc} TC</span>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>

          {/* Bottom: unified registered + pending table */}
          <div style={{ background: '#fff', border: '1px solid var(--color-border)', borderRadius: 6, overflow: 'hidden' }}>
            <div style={{ padding: '12px 16px', borderBottom: '1px solid var(--color-border)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 10 }}>
                <span style={{ fontWeight: 600, fontSize: 14 }}>Môn học đã đăng ký</span>
                <span style={{ color: '#888', fontSize: 13 }}>{allChosen.length} môn / {totalTc} tín chỉ</span>
              </div>
              {pending.length > 0 && (
                <div style={{ display: 'flex', gap: 8 }}>
                  <Button size="small" onClick={() => reg.reload()}>Hủy chọn mới</Button>
                  <Button
                    size="small"
                    type="primary"
                    loading={submitting}
                    onClick={submit}
                    style={{ background: 'var(--color-primary)', borderColor: 'var(--color-primary)' }}
                  >
                    Xác nhận ({pending.length} môn)
                  </Button>
                </div>
              )}
            </div>

            {allChosen.length > 0 ? (
              <Table
                rowKey="id"
                size="middle"
                dataSource={allChosen}
                columns={unifiedCols}
                pagination={false}
              />
            ) : (
              <div style={{ textAlign: 'center', color: '#999', padding: '28px 0', fontSize: 13 }}>
                Chưa đăng ký môn học nào
              </div>
            )}
          </div>
        </>
      )}

      {/* Row emphasis styles (Requirement 11) */}
      <style>{`
        .reg-row-passed td { opacity: 0.5; }
        .reg-row-full td { background: #fff7e6 !important; }
        .reg-row-even td { background: #fff; }
        .reg-row-odd td { background: #fafafa; }
        .ant-table-tbody > tr.reg-row-passed:hover > td,
        .ant-table-tbody > tr.reg-row-full:hover > td,
        .ant-table-tbody > tr.reg-row-even:hover > td,
        .ant-table-tbody > tr.reg-row-odd:hover > td {
          background: #e6f4ff !important;
        }
        @media (max-width: 1023px) {
          .fade-in > div[style*="grid-template-columns"] {
            grid-template-columns: 1fr !important;
          }
        }
      `}</style>
    </div>
  );
}
