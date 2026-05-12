import { useEffect, useState, useCallback } from 'react';
import { Card, Button, Space, Spin, message, Modal, Descriptions } from 'antd';
import { useParams } from 'react-router-dom';
import { teacherApi } from '../../../api/endpoints/teacher';
import GradeTable from './GradeTable';

export default function NhapDiem() {
  const { lhpId } = useParams();
  const [data, setData] = useState(null);
  const [dirty, setDirty] = useState({});
  const [saving, setSaving] = useState(false);

  const load = useCallback(() =>
    teacherApi.gradeBook(lhpId).then(setData).catch(console.error),
    [lhpId]);

  useEffect(() => { load(); }, [load]);

  const onCellChange = (dkId, ddId, v) => {
    setDirty(prev => ({ ...prev, [`${dkId}_${ddId}`]: v }));
    setData(prev => ({
      ...prev,
      rows: prev.rows.map(r => r.dangKyHocId === dkId
        ? { ...r, grades: { ...r.grades, [ddId]: v } } : r)
    }));
  };

  const save = async () => {
    const entries = Object.entries(dirty)
      .filter(([, v]) => v != null)
      .map(([k, v]) => {
        const [dk, dd] = k.split('_').map(Number);
        return { dangKyHocId: dk, dauDiemId: dd, diem: v };
      });
    if (entries.length === 0) return message.info('Chưa có thay đổi');
    setSaving(true);
    try {
      await teacherApi.saveGrades(Number(lhpId), entries);
      message.success(`Đã lưu ${entries.length} đầu điểm`);
      setDirty({});
    } catch (e) {
      message.error(e.response?.data?.message || 'Lỗi khi lưu');
    } finally { setSaving(false); }
  };

  const finalize = () => {
    Modal.confirm({
      title: 'Tổng kết môn?',
      content: 'Tính điểm tổng và gán hệ chữ cho tất cả SV. Có thể chạy lại nhiều lần.',
      okText: 'Tổng kết',
      onOk: async () => {
        try {
          const res = await teacherApi.finalize(Number(lhpId));
          message.success(`Tổng kết: ${res.done.length} SV thành công, ${res.failed.length} thất bại`);
          if (res.failed.length) {
            Modal.warning({
              title: 'SV chưa tổng kết được',
              content: <ul>{res.failed.map(f => <li key={f.dangKyHocId}>DK#{f.dangKyHocId}: {f.lyDo}</li>)}</ul>
            });
          }
          load();
        } catch (e) {
          message.error(e.response?.data?.message || 'Lỗi');
        }
      }
    });
  };

  if (!data) return <Spin />;

  return (
    <div className="fade-in">
      <Card style={{ marginBottom: 16 }}
        title={`Nhập điểm: ${data.tenLhp} — ${data.monHoc}`}
        extra={
          <Space>
            <Button loading={saving} onClick={save}>Lưu</Button>
            <Button type="primary" onClick={finalize}>Tổng kết môn</Button>
          </Space>
        }
      >
        <Descriptions size="small" column={3}>
          <Descriptions.Item label="Số TC">{data.soTc}</Descriptions.Item>
          <Descriptions.Item label="Số SV">{(data.rows || []).length}</Descriptions.Item>
          <Descriptions.Item label="Đầu điểm">
            {(data.dauDiems || []).map(d => `${d.ten} ${((d.tile || 0) * 100).toFixed(0)}%`).join(' · ')}
          </Descriptions.Item>
        </Descriptions>
      </Card>
      <Card>
        <GradeTable rows={data.rows || []} dauDiems={data.dauDiems || []} onCellChange={onCellChange} />
      </Card>
    </div>
  );
}
