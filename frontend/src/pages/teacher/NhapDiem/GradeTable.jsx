import { Table, Tag } from 'antd';
import EditableCell from './EditableCell';

export default function GradeTable({ rows, dauDiems, onCellChange }) {
  const cols = [
    { title: 'Mã SV', dataIndex: 'maSv', width: 120, fixed: 'left' },
    { title: 'Họ tên', dataIndex: 'hoTen', width: 200, fixed: 'left' },
    ...dauDiems.map(dd => ({
      title: `${dd.ten} (${((dd.tile || 0) * 100).toFixed(0)}%)`,
      key: `dd_${dd.id}`,
      width: 120,
      render: (_, row) => (
        <EditableCell value={row.grades?.[dd.id]}
          onChange={(v) => onCellChange(row.dangKyHocId, dd.id, v)} />
      ),
    })),
    { title: 'Điểm tổng', dataIndex: 'diemTong', width: 100,
      render: v => v != null ? v.toFixed(2) : '–' },
    { title: 'Hệ chữ', dataIndex: 'heChu', width: 90,
      render: v => v ? <Tag color="blue">{v}</Tag> : '–' },
  ];

  return (
    <Table rowKey="dangKyHocId" dataSource={rows} columns={cols}
      scroll={{ x: 'max-content' }} pagination={false} size="small" />
  );
}
