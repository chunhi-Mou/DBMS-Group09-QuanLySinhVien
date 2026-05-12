import { Table, Tag, Popconfirm, Button } from 'antd';
import { Trash2 } from 'lucide-react';

export default function ScheduleAdminGrid({ rows, onDelete }) {
  return (
    <Table size="small" rowKey="id" dataSource={rows} pagination={{ pageSize: 50 }}
      columns={[
        { title: 'Tuần', dataIndex: 'tuanId', width: 70 },
        { title: 'Ngày', dataIndex: 'ngayId', width: 70 },
        { title: 'Kíp', dataIndex: 'kipId', width: 60 },
        { title: 'Phòng', dataIndex: 'phongTen' },
        { title: 'LHP', render: (_, r) => <Tag color="red">{r.tenLhp}</Tag> },
        { title: 'Môn', dataIndex: 'monHoc' },
        { title: 'GV', dataIndex: 'giangVienTen' },
        {
          title: '', render: (_, r) => (
            <Popconfirm title="Xóa buổi học?" onConfirm={() => onDelete(r.id)}>
              <Button size="small" danger icon={<Trash2 size={12} />} />
            </Popconfirm>
          )
        },
      ]}
    />
  );
}
