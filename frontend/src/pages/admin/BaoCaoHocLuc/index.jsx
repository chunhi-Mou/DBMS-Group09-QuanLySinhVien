import { useEffect, useState } from 'react';
import { Card, Select, Row, Col, Spin, Tag, Table } from 'antd';
import { Pie } from '@ant-design/charts';
import { adminApi } from '../../../api/endpoints/admin';

export default function BaoCaoHocLuc() {
  const [kis, setKis] = useState([]);
  const [kiId, setKiId] = useState(null);
  const [data, setData] = useState(null);

  useEffect(() => { adminApi.kiHocs().then(setKis); }, []);
  useEffect(() => {
    if (!kiId) return;
    setData(null);
    adminApi.reportHocLuc(kiId).then(setData);
  }, [kiId]);

  return (
    <div className="fade-in">
      <Card style={{ marginBottom: 16 }}>
        <Select placeholder="Chọn kỳ" value={kiId} onChange={setKiId} style={{ width: 280 }}
          options={kis.map(k => ({ value: k.id, label: `${k.namHocTen} — ${k.hocKiTen}` }))} />
      </Card>
      {kiId && (data == null ? <Spin /> : (
        <Row gutter={16}>
          <Col span={10}>
            <Card title={`Phân bổ học lực — ${data.kiHocTen}`}>
              <Pie data={data.phanBo.map(d => ({ type: d.loaiHocLuc ?? 'Chưa xếp', value: Number(d.soLuong) }))}
                angleField="value" colorField="type" radius={0.8}
                label={{ type: 'outer', content: '{name} {percentage}' }}
                animation={{ appear: { animation: 'wave-in', duration: 800 } }}
              />
            </Card>
          </Col>
          <Col span={14}>
            <Card title="Danh sách SV">
              <Table size="small" rowKey="maSv" dataSource={data.sinhVien} pagination={{ pageSize: 30 }}
                columns={[
                  { title: 'Mã SV', dataIndex: 'maSv' },
                  { title: 'Họ tên', dataIndex: 'hoTen' },
                  { title: 'GPA10', dataIndex: 'gpa10' },
                  { title: 'GPA4', dataIndex: 'gpa4' },
                  { title: 'TC đạt', render: (_, r) => `${r.tcDat}/${r.tongTc}` },
                  { title: 'Học lực', dataIndex: 'hocLuc', render: v => v ? <Tag color="red">{v}</Tag> : '–' },
                ]} />
            </Card>
          </Col>
        </Row>
      ))}
    </div>
  );
}
